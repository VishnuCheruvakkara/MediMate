import 'package:flutter/material.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/fever/domain/temperature_unit.dart';
import 'package:medimate/features/fever/presentation/fever_formatters.dart';

class FeverSummaryCard extends StatefulWidget {
  const FeverSummaryCard({
    super.key,
    required this.entry,
    this.unit = TemperatureUnit.celsius,
  });

  final FeverEntry? entry;
  final TemperatureUnit unit;

  @override
  State<FeverSummaryCard> createState() => _FeverSummaryCardState();
}

class _FeverSummaryCardState extends State<FeverSummaryCard> {
  late TemperatureUnit _unit;

  @override
  void initState() {
    super.initState();
    _unit = widget.unit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: const Color(0xFF173F39),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.thermostat,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.entry == null ? 'No readings yet' : 'Latest reading',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.entry == null
                        ? 'Add your first temperature'
                        : _unit.format(widget.entry!.temperatureC),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (widget.entry != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      formatFeverDateTime(context, widget.entry!.measuredAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<TemperatureUnit>(
                      key: const Key('latestReadingUnitTabs'),
                      segments: const [
                        ButtonSegment(
                          value: TemperatureUnit.celsius,
                          label: Text('°C'),
                        ),
                        ButtonSegment(
                          value: TemperatureUnit.fahrenheit,
                          label: Text('°F'),
                        ),
                      ],
                      selected: {_unit},
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? const Color(0xFF173F39)
                              : Colors.white,
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? Colors.white
                              : Colors.transparent,
                        ),
                        side: const WidgetStatePropertyAll(
                          BorderSide(color: Colors.white54),
                        ),
                      ),
                      onSelectionChanged: (selection) {
                        setState(() => _unit = selection.first);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
