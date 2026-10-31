import 'package:flutter/material.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/fever/domain/temperature_unit.dart';

class FeverEntrySheet extends StatefulWidget {
  const FeverEntrySheet({
    super.key,
    this.initial,
    this.initialUnit = TemperatureUnit.celsius,
  });
  final FeverEntry? initial;
  final TemperatureUnit initialUnit;

  @override
  State<FeverEntrySheet> createState() => _FeverEntrySheetState();
}

class _FeverEntrySheetState extends State<FeverEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _temperatureController;
  late final TextEditingController _symptomsController;
  late final TextEditingController _notesController;
  late DateTime _measuredAt;
  late String _method;
  late bool _medicineTaken;
  late TemperatureUnit _unit;

  static const _methods = {
    'oral': 'Oral',
    'axillary': 'Underarm',
    'tympanic': 'Ear',
    'temporal': 'Forehead',
    'rectal': 'Rectal',
    'other': 'Other',
  };

  @override
  void initState() {
    super.initState();
    final entry = widget.initial;
    _unit = widget.initialUnit;
    final initialTemperature = entry == null
        ? null
        : _unit.displayValue(entry.temperatureC);
    _temperatureController = TextEditingController(
      text: initialTemperature?.toStringAsFixed(1) ?? '',
    );
    _symptomsController = TextEditingController(
      text: entry?.symptoms.join(', ') ?? '',
    );
    _notesController = TextEditingController(text: entry?.notes ?? '');
    _measuredAt = entry?.measuredAt ?? DateTime.now();
    _method = entry?.measurementMethod ?? 'oral';
    _medicineTaken = entry?.medicineTaken ?? false;
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
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
                widget.initial == null ? 'Add temperature' : 'Edit entry',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Record what you measured. MediMate does not diagnose illness.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const Key('temperatureField'),
                controller: _temperatureController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Temperature',
                  prefixIcon: const Icon(Icons.thermostat_outlined),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TemperatureUnit>(
                        key: const Key('temperatureUnitField'),
                        value: _unit,
                        borderRadius: BorderRadius.circular(14),
                        items: const [
                          DropdownMenuItem(
                            value: TemperatureUnit.celsius,
                            child: Text('°C'),
                          ),
                          DropdownMenuItem(
                            value: TemperatureUnit.fahrenheit,
                            child: Text('°F'),
                          ),
                        ],
                        onChanged: (unit) {
                          if (unit != null) _changeUnit(unit);
                        },
                      ),
                    ),
                  ),
                ),
                validator: (value) {
                  final temperature = double.tryParse(value?.trim() ?? '');
                  if (temperature == null) return 'Enter a temperature';
                  final minimum = _unit == TemperatureUnit.celsius ? 30 : 86;
                  final maximum = _unit == TemperatureUnit.celsius ? 45 : 113;
                  if (temperature < minimum || temperature > maximum) {
                    final symbol = _unit == TemperatureUnit.celsius
                        ? '°C'
                        : '°F';
                    return '$minimum–$maximum$symbol allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _method,
                decoration: const InputDecoration(
                  labelText: 'Measurement method',
                  prefixIcon: Icon(Icons.device_thermostat),
                ),
                items: _methods.entries
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.key,
                        child: Text(item.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _method = value ?? 'other'),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.schedule),
                label: Text(_dateTimeLabel(_measuredAt)),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(18),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _symptomsController,
                decoration: const InputDecoration(
                  labelText: 'Symptoms',
                  hintText: 'Headache, fatigue',
                  helperText: 'Separate symptoms with commas',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: const Text('Medicine taken'),
                subtitle: const Text(
                  'Only record medicine already prescribed or advised',
                ),
                value: _medicineTaken,
                onChanged: (value) => setState(() => _medicineTaken = value),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                key: const Key('saveEntryButton'),
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: Text(
                  widget.initial == null ? 'Save entry' : 'Save changes',
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

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _measuredAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_measuredAt),
    );
    if (time == null) return;
    setState(() {
      _measuredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final symptoms = _symptomsController.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    final enteredTemperature = double.parse(_temperatureController.text.trim());
    final temperatureC = _unit.toCelsius(enteredTemperature);
    Navigator.pop(
      context,
      FeverEntryInput(
        temperatureC: temperatureC,
        measuredAt: _measuredAt,
        measurementMethod: _method,
        symptoms: symptoms,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        medicineTaken: _medicineTaken,
      ),
    );
  }

  void _changeUnit(TemperatureUnit nextUnit) {
    if (nextUnit == _unit) return;
    final currentValue = double.tryParse(_temperatureController.text.trim());
    setState(() {
      if (currentValue != null) {
        final celsius = _unit.toCelsius(currentValue);
        _temperatureController.text = nextUnit
            .displayValue(celsius)
            .toStringAsFixed(1);
      }
      _unit = nextUnit;
    });
  }

  String _dateTimeLabel(DateTime date) {
    final time = TimeOfDay.fromDateTime(date).format(context);
    return '${date.day}/${date.month}/${date.year} at $time';
  }
}
