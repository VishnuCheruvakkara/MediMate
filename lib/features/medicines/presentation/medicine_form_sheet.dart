import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medimate/features/medicines/domain/medicine.dart';

class MedicineFormSheet extends StatefulWidget {
  const MedicineFormSheet({super.key, this.initial});
  final Medicine? initial;

  @override
  State<MedicineFormSheet> createState() => _MedicineFormSheetState();
}

class _MedicineFormSheetState extends State<MedicineFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _intervalController;
  late List<TimeOfDay> _times;
  late bool _isActive;
  String? _scheduleError;

  @override
  void initState() {
    super.initState();
    final medicine = widget.initial;
    _nameController = TextEditingController(text: medicine?.name ?? '');
    _dosageController = TextEditingController(text: medicine?.dosage ?? '');
    _instructionsController = TextEditingController(
      text: medicine?.instructions ?? '',
    );
    _times = medicine?.schedules.map(_parseTime).toList() ?? [];
    _intervalController = TextEditingController(
      text: medicine?.schedules.firstOrNull?.intervalDays.toString() ?? '1',
    );
    _isActive = medicine?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.initial == null ? 'Add medicine' : 'Edit medicine',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use the medicine and dosage instructions provided by your clinician.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const Key('medicineNameField'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Medicine name',
                  prefixIcon: Icon(Icons.medication_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the medicine name'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('medicineDosageField'),
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'For example: 1 tablet',
                  prefixIcon: Icon(Icons.science_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the prescribed dosage'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _instructionsController,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Instructions (optional)',
                  hintText: 'For example: after food',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 4),
              Text('Dose schedule', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._times.map(
                    (time) => InputChip(
                      label: Text(time.format(context)),
                      avatar: const Icon(Icons.schedule, size: 17),
                      onDeleted: () => setState(() => _times.remove(time)),
                    ),
                  ),
                  ActionChip(
                    key: const Key('addDoseTimeButton'),
                    avatar: const Icon(Icons.add, size: 18),
                    label: const Text('Add time'),
                    onPressed: _addTime,
                  ),
                ],
              ),
              if (_scheduleError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _scheduleError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              TextFormField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Repeat every',
                  suffixText: 'day(s)',
                  prefixIcon: Icon(Icons.repeat),
                ),
                validator: (value) {
                  final days = int.tryParse(value ?? '');
                  if (days == null || days < 1 || days > 365) {
                    return 'Enter 1 to 365 days';
                  }
                  return null;
                },
              ),
              if (widget.initial != null)
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: const Text('Active medicine'),
                  subtitle: const Text(
                    'Inactive medicines remain in your history',
                  ),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const Key('saveMedicineButton'),
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: Text(
                  widget.initial == null ? 'Save medicine' : 'Save changes',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _times.lastOrNull ?? TimeOfDay.now(),
    );
    if (time == null) return;
    if (_times.any(
      (item) => item.hour == time.hour && item.minute == time.minute,
    )) {
      return;
    }
    setState(() {
      _times.add(time);
      _times.sort((a, b) => a.hour * 60 + a.minute - b.hour * 60 - b.minute);
      _scheduleError = null;
    });
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    if (_times.isEmpty) {
      setState(() => _scheduleError = 'Add at least one dose time');
    }
    if (!valid || _times.isEmpty) return;
    final interval = int.parse(_intervalController.text);
    Navigator.pop(
      context,
      MedicineInput(
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        isActive: _isActive,
        schedules: _times
            .map(
              (time) => MedicineSchedule(
                timeOfDay:
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
                intervalDays: interval,
              ),
            )
            .toList(),
      ),
    );
  }

  TimeOfDay _parseTime(MedicineSchedule schedule) {
    final parts = schedule.timeOfDay.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
