import 'package:flutter/material.dart';
import 'package:medimate/core/widgets/app_brand_title.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/fever/presentation/fever_tracker_page.dart';
import 'package:medimate/features/medicines/domain/medicine.dart';
import 'package:medimate/features/medicines/presentation/medicine_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.medicineRepository,
    required this.feverRepository,
    this.initialIndex = 0,
  });

  final MedicineRepository medicineRepository;
  final FeverRepository feverRepository;
  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppBrandTitle()),
      body: IndexedStack(
        index: _index,
        children: [
          MedicinePage(repository: widget.medicineRepository),
          FeverTrackerPage(
            repository: widget.feverRepository,
            showAppBar: false,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Medicines',
          ),
          NavigationDestination(
            icon: Icon(Icons.thermostat_outlined),
            selectedIcon: Icon(Icons.thermostat),
            label: 'Fever',
          ),
        ],
      ),
    );
  }
}
