import 'package:flutter/material.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/fever/domain/temperature_unit.dart';
import 'package:medimate/features/fever/presentation/fever_formatters.dart';

class FeverEntryCard extends StatelessWidget {
  const FeverEntryCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    this.unit = TemperatureUnit.celsius,
  });

  final FeverEntry entry;
  final TemperatureUnit unit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = entry.notes;
    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 10, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                unit.format(entry.temperatureC),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatFeverDateTime(context, entry.measuredAt),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatMeasurementMethod(entry.measurementMethod),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (entry.symptoms.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: entry.symptoms
                          .map(
                            (symptom) => Chip(
                              label: Text(symptom),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (entry.medicineTaken) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        const Text('Medicine recorded'),
                      ],
                    ),
                  ],
                  if (notes != null && notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(notes, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
