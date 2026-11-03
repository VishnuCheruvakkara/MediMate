import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimate/app/app.dart';
import 'package:medimate/app/home_shell.dart';
import 'package:medimate/features/auth/domain/auth_repository.dart';
import 'package:medimate/features/auth/domain/auth_user.dart';
import 'package:medimate/features/auth/presentation/login_signup_page.dart';
import 'package:medimate/features/auth/presentation/onboarding_page.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/medicines/domain/medicine.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.currentUser});
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

class FakeFeverRepository implements FeverRepository {
  @override
  Future<List<FeverEntry>> listEntries() async => [];
  @override
  Future<FeverEntry> createEntry(FeverEntryInput input) async => throw UnimplementedError();
  @override
  Future<void> deleteEntry(String id) async {}
  @override
  Future<FeverEntry> updateEntry(String id, FeverEntryInput input) async => throw UnimplementedError();
}

class FakeMedicineRepository implements MedicineRepository {
  @override
  Future<List<Medicine>> listMedicines() async => [];
  @override
  Future<Medicine> createMedicine(MedicineInput input) async => throw UnimplementedError();
  @override
  Future<void> deleteMedicine(String id) async {}
  @override
  Future<Medicine> updateMedicine(String id, MedicineInput input) async => throw UnimplementedError();
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

  testWidgets('launches into Onboarding and continues as guest to HomeShell', (
    tester,
  ) async {
    final authRepo = FakeAuthRepository();
    final medRepo = FakeMedicineRepository();
    final fevRepo = FakeFeverRepository();

    await tester.pumpWidget(
      MediMateApp(
        showOnboarding: true,
        authRepository: authRepo,
        medicineRepository: medRepo,
        repository: fevRepo,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);

    await tester.tap(find.byKey(const Key('continueAsGuestButton')));
    await tester.pumpAndSettle();

    // Now in HomeShell
    expect(find.byKey(const Key('accountProfileButton')), findsOneWidget);
    expect(find.text('Medicines'), findsWidgets);
  });

  testWidgets('opens account sheet in HomeShell and displays guest mode', (
    tester,
  ) async {
    final authRepo = FakeAuthRepository(); // no user logged in
    final medRepo = FakeMedicineRepository();
    final fevRepo = FakeFeverRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeShell(
          authRepository: authRepo,
          medicineRepository: medRepo,
          feverRepository: fevRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('accountProfileButton')));
    await tester.pumpAndSettle();

    expect(find.text('Guest User'), findsOneWidget);
    expect(find.text('Offline profile mode'), findsOneWidget);
    expect(find.byKey(const Key('accountLoginButton')), findsOneWidget);
  });

  testWidgets('opens account sheet for logged-in user and signs out to onboarding', (
    tester,
  ) async {
    final authRepo = FakeAuthRepository(
      currentUser: const AuthUser(
        id: 'user-1',
        email: 'alex@example.com',
        name: 'Alex Rivera',
      ),
    );
    final medRepo = FakeMedicineRepository();
    final fevRepo = FakeFeverRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeShell(
          authRepository: authRepo,
          medicineRepository: medRepo,
          feverRepository: fevRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('accountProfileButton')));
    await tester.pumpAndSettle();

    expect(find.text('Alex Rivera'), findsOneWidget);
    expect(find.text('alex@example.com'), findsOneWidget);
    expect(find.byKey(const Key('accountLogoutButton')), findsOneWidget);

    // Sign out
    await tester.tap(find.byKey(const Key('accountLogoutButton')));
    await tester.pumpAndSettle();

    // Returns to OnboardingPage
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });
}
