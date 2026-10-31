import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medimate/core/config/app_config.dart';
import 'package:medimate/features/medicines/domain/medicine.dart';

class MedicineApiException implements Exception {
  const MedicineApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class MedicineApiRepository implements MedicineRepository {
  MedicineApiRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;
  Uri get _collection => Uri.parse('$_baseUrl/api/v1/medicines');

  @override
  Future<List<Medicine>> listMedicines() async {
    final response = await _client.get(_collection);
    _ensureSuccess(response);
    return (jsonDecode(response.body) as List<dynamic>)
        .map((item) => Medicine.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Medicine> createMedicine(MedicineInput input) async {
    final response = await _client.post(
      _collection,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(input.toCreateJson()),
    );
    _ensureSuccess(response);
    return Medicine.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<Medicine> updateMedicine(String id, MedicineInput input) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/api/v1/medicines/$id'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(input.toUpdateJson()),
    );
    _ensureSuccess(response);
    return Medicine.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteMedicine(String id) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/api/v1/medicines/$id'),
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
      // Keep the safe fallback for non-JSON responses.
    }
    throw MedicineApiException(message);
  }
}
