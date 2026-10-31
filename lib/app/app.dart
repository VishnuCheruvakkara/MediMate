import 'package:flutter/material.dart';
import 'package:medimate/features/fever/data/fever_api_repository.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/fever/presentation/fever_tracker_page.dart';

class MediMateApp extends StatelessWidget {
  const MediMateApp({super.key, this.repository});

  final FeverRepository? repository;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3C7A6E),
      surface: const Color(0xFFF8FAF8),
    );
    return MaterialApp(
      title: 'MediMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F7F5),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF1F5F3),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: FeverTrackerPage(repository: repository ?? FeverApiRepository()),
    );
  }
}
