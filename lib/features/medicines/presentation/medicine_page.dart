import 'package:flutter/material.dart';
import 'package:medimate/core/widgets/app_confirm_dialog.dart';
import 'package:medimate/core/widgets/app_empty_state.dart';
import 'package:medimate/core/widgets/app_error_state.dart';
import 'package:medimate/core/widgets/app_loading_state.dart';
import 'package:medimate/core/widgets/app_page_header.dart';
import 'package:medimate/core/widgets/app_section_header.dart';
import 'package:medimate/features/medicines/domain/medicine.dart';
import 'package:medimate/features/medicines/presentation/medicine_card.dart';
import 'package:medimate/features/medicines/presentation/medicine_form_sheet.dart';

class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key, required this.repository});
  final MedicineRepository repository;

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  List<Medicine> _medicines = const [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addMedicineButton'),
        onPressed: _saving ? null : () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add medicine'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMedicines,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              sliver: SliverList.list(
                children: [
                  const AppPageHeader(
                    title: 'My medicines',
                    description:
                        'Keep prescribed medicines and dose times together.',
                  ),
                  const SizedBox(height: 26),
                  AppSectionHeader(
                    title: 'Schedule',
                    trailing: _medicines.isEmpty
                        ? null
                        : Text(
                            '${_medicines.length} ${_medicines.length == 1 ? 'medicine' : 'medicines'}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const AppLoadingState()
                  else if (_error != null)
                    AppErrorState(message: _error!, onRetry: _loadMedicines)
                  else if (_medicines.isEmpty)
                    const AppEmptyState(
                      icon: Icons.medication_outlined,
                      title: 'No medicines added',
                      message:
                          'Tap “Add medicine” to create your first schedule.',
                    )
                  else
                    ..._medicines.map(
                      (medicine) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MedicineCard(
                          medicine: medicine,
                          onEdit: () => _openForm(medicine),
                          onDelete: () => _confirmDelete(medicine),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadMedicines() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final medicines = await widget.repository.listMedicines();
      if (!mounted) return;
      setState(() {
        _medicines = medicines;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load medicines. Make sure FastAPI is running.';
      });
    }
  }

  Future<void> _openForm([Medicine? medicine]) async {
    final input = await showModalBottomSheet<MedicineInput>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => MedicineFormSheet(initial: medicine),
    );
    if (input == null || !mounted) return;
    setState(() => _saving = true);
    try {
      if (medicine == null) {
        await widget.repository.createMedicine(input);
      } else {
        await widget.repository.updateMedicine(medicine.id, input);
      }
      await _loadMedicines();
      if (mounted) {
        _showMessage(medicine == null ? 'Medicine saved' : 'Medicine updated');
      }
    } catch (_) {
      if (mounted) _showMessage('Could not save the medicine.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete(Medicine medicine) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Delete ${medicine.name}?',
      message: 'This removes its schedules and cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;
    try {
      await widget.repository.deleteMedicine(medicine.id);
      await _loadMedicines();
      if (mounted) _showMessage('Medicine deleted');
    } catch (_) {
      if (mounted) _showMessage('Could not delete the medicine.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
