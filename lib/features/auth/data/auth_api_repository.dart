import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medimate/core/config/app_config.dart';
import 'package:medimate/features/auth/domain/auth_repository.dart';
import 'package:medimate/features/auth/domain/auth_user.dart';

class AuthApiException implements Exception {
  const AuthApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthApiRepository implements AuthRepository {
  AuthApiRepository({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  AuthUser? _cachedUser;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/v1/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );
    _ensureSuccess(response);
    final user = AuthUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    _cachedUser = user;
    return user;
  }

  @override
  Future<AuthUser> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/v1/auth/signup'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );
    _ensureSuccess(response);
    final user = AuthUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    _cachedUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _cachedUser = null;
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    return _cachedUser;
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded.containsKey('detail')) {
        throw AuthApiException(decoded['detail'].toString());
      }
    } catch (e) {
      if (e is AuthApiException) rethrow;
    }
    throw AuthApiException(
      'Authentication failed (${response.statusCode}): ${response.reasonPhrase ?? 'Unknown error'}',
    );
  }
}

