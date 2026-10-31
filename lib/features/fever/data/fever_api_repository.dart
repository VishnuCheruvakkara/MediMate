import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medimate/core/config/app_config.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';

class FeverApiException implements Exception {
  const FeverApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class FeverApiRepository implements FeverRepository {
  FeverApiRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;
  Uri get _collection => Uri.parse('$_baseUrl/api/v1/fever-entries');

  @override
  Future<List<FeverEntry>> listEntries() async {
    final response = await _client.get(_collection);
    _ensureSuccess(response);
    final items = jsonDecode(response.body) as List<dynamic>;
    return items
        .map((item) => FeverEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FeverEntry> createEntry(FeverEntryInput input) async {
    final response = await _client.post(
      _collection,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );
    _ensureSuccess(response);
    return FeverEntry.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<FeverEntry> updateEntry(String id, FeverEntryInput input) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/api/v1/fever-entries/$id'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );
    _ensureSuccess(response);
    return FeverEntry.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteEntry(String id) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/api/v1/fever-entries/$id'),
    );
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    var message = 'The server could not complete this request.';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['detail']?.toString() ?? message;
    } on FormatException {
      // Keep the fallback for non-JSON responses.
    }
    throw FeverApiException(message);
  }
}
