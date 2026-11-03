import 'package:flutter/material.dart';
import 'package:medimate/app/home_shell.dart';
import 'package:medimate/app/theme/app_theme.dart';
import 'package:medimate/features/auth/data/auth_api_repository.dart';
import 'package:medimate/features/auth/domain/auth_repository.dart';
import 'package:medimate/features/auth/presentation/onboarding_page.dart';
import 'package:medimate/features/fever/data/fever_api_repository.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/medicines/data/medicine_api_repository.dart';
import 'package:medimate/features/medicines/domain/medicine.dart';

class MediMateApp extends StatelessWidget {
  const MediMateApp({
    super.key,
    this.repository,
    this.medicineRepository,
    this.authRepository,
    this.initialIndex = 0,
    this.showOnboarding = false,
  });

  final FeverRepository? repository;
  final MedicineRepository? medicineRepository;
  final AuthRepository? authRepository;
  final int initialIndex;
  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    final medRepo = medicineRepository ?? MedicineApiRepository();
    final fevRepo = repository ?? FeverApiRepository();
    final authRepo = authRepository ?? AuthApiRepository();

    return MaterialApp(
      title: 'MediMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: showOnboarding
          ? OnboardingPage(
              authRepository: authRepo,
              medicineRepository: medRepo,
              feverRepository: fevRepo,
            )
          : HomeShell(
              medicineRepository: medRepo,
              feverRepository: fevRepo,
              authRepository: authRepo,
              initialIndex: initialIndex,
            ),
    );
  }
}
