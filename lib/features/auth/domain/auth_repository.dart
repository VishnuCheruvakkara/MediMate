import 'package:medimate/features/auth/domain/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login({required String email, required String password});
  Future<AuthUser> signup({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<AuthUser?> getCurrentUser();
}

