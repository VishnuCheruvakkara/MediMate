import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimate/features/auth/domain/auth_repository.dart';
import 'package:medimate/features/auth/domain/auth_user.dart';
import 'package:medimate/features/auth/presentation/login_signup_page.dart';
import 'package:medimate/features/auth/presentation/onboarding_page.dart';

class FakeAuthRepository implements AuthRepository {
  AuthUser? currentUser;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final user = AuthUser(id: 'test-user', email: email, name: 'Test User');
    currentUser = user;
    return user;
  }

  @override
  Future<AuthUser> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = AuthUser(id: 'test-user', email: email, name: name);
    currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    currentUser = null;
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    return currentUser;
  }
}

void main() {
  testWidgets('renders OnboardingPage with features and action buttons', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));

    expect(find.text('MediMate'), findsOneWidget);
    expect(find.text('Medicine Schedules'), findsOneWidget);
    expect(find.text('Fever & Symptom Log'), findsOneWidget);
    expect(find.text('Works Offline'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });

  testWidgets('renders LoginSignupPage and switches between modes', (
    tester,
  ) async {
    final authRepo = FakeAuthRepository();
    await tester.pumpWidget(
      MaterialApp(home: LoginSignupPage(authRepository: authRepo)),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log In'), findsWidgets);

    // Switch to Sign Up
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
  });
}

