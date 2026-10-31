import 'package:flutter/material.dart';
import 'package:medimate/app/theme/app_theme.dart';
import 'package:medimate/app/home_shell.dart';
import 'package:medimate/features/fever/data/fever_api_repository.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/medicines/data/medicine_api_repository.dart';
import 'package:medimate/features/medicines/domain/medicine.dart';

class MediMateApp extends StatelessWidget {
  const MediMateApp({
    super.key,
    this.repository,
    this.medicineRepository,
    this.initialIndex = 0,
  });

  final FeverRepository? repository;
  final MedicineRepository? medicineRepository;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: HomeShell(
        medicineRepository: medicineRepository ?? MedicineApiRepository(),
        feverRepository: repository ?? FeverApiRepository(),
        initialIndex: initialIndex,
      ),
    );
  }
}
