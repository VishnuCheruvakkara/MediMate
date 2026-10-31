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
  late final TextEditingController _repeatDaysController;
  late final TextEditingController _dosePatternController;
  late final TextEditingController _intervalHoursController;
  late List<TimeOfDay> _times;
  late String _foodTiming;
  late String _scheduleMode;
  TimeOfDay? _intervalStartTime;
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
    _dosePatternController = TextEditingController(
      text: medicine?.dosePattern ?? '',
    );
    _times = medicine?.schedules.map(_parseTime).toList() ?? [];
    _repeatDaysController = TextEditingController(
      text: medicine?.schedules.firstOrNull?.intervalDays.toString() ?? '1',
    );
    _intervalHoursController = TextEditingController(
      text: medicine?.intervalHours?.toString() ?? '4',
    );
    _foodTiming = medicine?.foodTiming ?? 'as_directed';
    _scheduleMode = medicine?.scheduleMode ?? 'fixed_times';
    _intervalStartTime = medicine?.intervalStartTime == null
        ? null
        : _parseTimeValue(medicine!.intervalStartTime!);
    _isActive = medicine?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _repeatDaysController.dispose();
    _dosePatternController.dispose();
    _intervalHoursController.dispose();
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
              DropdownButtonFormField<String>(
                initialValue: _foodTiming,
                decoration: const InputDecoration(
                  labelText: 'Food timing',
                  prefixIcon: Icon(Icons.restaurant_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'before_food',
                    child: Text('Before food'),
                  ),
                  DropdownMenuItem(
                    value: 'after_food',
                    child: Text('After food'),
                  ),
                  DropdownMenuItem(
                    value: 'with_food',
                    child: Text('With food'),
                  ),
                  DropdownMenuItem(
                    value: 'empty_stomach',
                    child: Text('On an empty stomach'),
                  ),
                  DropdownMenuItem(value: 'anytime', child: Text('Any time')),
                  DropdownMenuItem(
                    value: 'as_directed',
                    child: Text('As directed'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _foodTiming = value);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('dosePatternField'),
                controller: _dosePatternController,
                decoration: const InputDecoration(
                  labelText: 'Prescription pattern (optional)',
                  hintText: 'For example: 1-1-1 or 1-0-1',
                  helperText:
                      'Record the prescribed amount for each dose period',
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final parts = value.trim().split('-');
                  if (parts.isEmpty || parts.length > 4) {
                    return 'Use one to four dose periods';
                  }
                  if (parts.any((part) => double.tryParse(part) == null)) {
                    return 'Use numbers separated by hyphens';
                  }
                  return null;
                },
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
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'fixed_times',
                    icon: Icon(Icons.schedule),
                    label: Text('Exact times'),
                  ),
                  ButtonSegment(
                    value: 'interval',
                    icon: Icon(Icons.timelapse),
                    label: Text('Hourly gap'),
                  ),
                ],
                selected: {_scheduleMode},
                onSelectionChanged: (selection) {
                  setState(() {
                    _scheduleMode = selection.first;
                    _scheduleError = null;
                  });
                },
              ),
              const SizedBox(height: 14),
              if (_scheduleMode == 'fixed_times') ...[
                Text(
                  'Add the exact times written or explained by the clinician.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
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
                const SizedBox(height: 14),
                TextFormField(
                  controller: _repeatDaysController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Repeat every',
                    suffixText: 'day(s)',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  validator: _scheduleMode == 'fixed_times'
                      ? (value) {
                          final days = int.tryParse(value ?? '');
                          if (days == null || days < 1 || days > 365) {
                            return 'Enter 1 to 365 days';
                          }
                          return null;
                        }
                      : null,
                ),
              ] else ...[
                Text(
                  'Choose the exact gap and the first dose time from the prescription.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [2, 4, 6, 8, 12]
                      .map(
                        (hours) => ActionChip(
                          label: Text('$hours hours'),
                          onPressed: () => setState(
                            () => _intervalHoursController.text = '$hours',
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const Key('intervalHoursField'),
                  controller: _intervalHoursController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Gap between doses',
                    suffixText: 'hour(s)',
                    prefixIcon: Icon(Icons.timelapse),
                  ),
                  validator: _scheduleMode == 'interval'
                      ? (value) {
                          final hours = int.tryParse(value ?? '');
                          if (hours == null || hours < 1 || hours > 24) {
                            return 'Enter 1 to 24 hours';
                          }
                          return null;
                        }
                      : null,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: const Key('intervalStartTimeButton'),
                  onPressed: _pickIntervalStartTime,
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(
                    _intervalStartTime == null
                        ? 'Choose first dose time'
                        : 'First dose: ${_intervalStartTime!.format(context)}',
                  ),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(18),
                  ),
                ),
              ],
              if (_scheduleError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _scheduleError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
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

  Future<void> _pickIntervalStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _intervalStartTime ?? TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _intervalStartTime = time;
      _scheduleError = null;
    });
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    if (_scheduleMode == 'fixed_times' && _times.isEmpty) {
      setState(() => _scheduleError = 'Add at least one dose time');
    } else if (_scheduleMode == 'interval' && _intervalStartTime == null) {
      setState(() => _scheduleError = 'Choose the first dose time');
    }
    final scheduleIsValid = _scheduleMode == 'fixed_times'
        ? _times.isNotEmpty
        : _intervalStartTime != null;
    if (!valid || !scheduleIsValid) return;
    final repeatDays = int.parse(_repeatDaysController.text);
    Navigator.pop(
      context,
      MedicineInput(
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        foodTiming: _foodTiming,
        dosePattern: _dosePatternController.text.trim().isEmpty
            ? null
            : _dosePatternController.text.trim(),
        scheduleMode: _scheduleMode,
        intervalHours: _scheduleMode == 'interval'
            ? int.parse(_intervalHoursController.text)
            : null,
        intervalStartTime: _scheduleMode == 'interval'
            ? _formatTime(_intervalStartTime!)
            : null,
        isActive: _isActive,
        schedules: (_scheduleMode == 'fixed_times' ? _times : <TimeOfDay>[])
            .map(
              (time) => MedicineSchedule(
                timeOfDay: _formatTime(time),
                intervalDays: repeatDays,
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

  TimeOfDay _parseTimeValue(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }
}
