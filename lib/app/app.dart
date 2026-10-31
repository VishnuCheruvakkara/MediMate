import 'package:flutter/material.dart';
import 'package:medimate/app/theme/app_theme.dart';
import 'package:medimate/features/fever/data/fever_api_repository.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/fever/presentation/fever_tracker_page.dart';

class MediMateApp extends StatelessWidget {
  const MediMateApp({super.key, this.repository});

  final FeverRepository? repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: FeverTrackerPage(repository: repository ?? FeverApiRepository()),
    );
  }
}
