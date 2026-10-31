import 'package:flutter/material.dart';
import 'package:medimate/features/medicines/domain/medicine.dart';

class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
  });

  final Medicine medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 10, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: medicine.isActive
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.medication,
                color: medicine.isActive
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          medicine.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (!medicine.isActive)
                        const Chip(
                          label: Text('Inactive'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    medicine.dosage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (medicine.instructions case final instructions?
                      when instructions.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      instructions,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.restaurant_outlined, size: 16),
                        label: Text(_foodTimingLabel(medicine.foodTiming)),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (medicine.dosePattern != null)
                        Chip(
                          avatar: const Icon(
                            Icons.format_list_numbered,
                            size: 16,
                          ),
                          label: Text(medicine.dosePattern!),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (medicine.scheduleMode == 'interval')
                    Chip(
                      avatar: const Icon(Icons.timelapse, size: 16),
                      label: Text(_intervalLabel(context, medicine)),
                      visualDensity: VisualDensity.compact,
                    )
                  else if (medicine.schedules.isEmpty)
                    Text(
                      'No dose times',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: medicine.schedules
                          .map(
                            (schedule) => Chip(
                              avatar: const Icon(Icons.schedule, size: 16),
                              label: Text(_scheduleLabel(context, schedule)),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
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

  String _scheduleLabel(BuildContext context, MedicineSchedule schedule) {
    final parts = schedule.timeOfDay.split(':');
    final time = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    ).format(context);
    if (schedule.intervalDays == 1) return time;
    return '$time · every ${schedule.intervalDays} days';
  }

  String _intervalLabel(BuildContext context, Medicine medicine) {
    final start = medicine.intervalStartTime;
    if (start == null || medicine.intervalHours == null) {
      return 'Interval schedule';
    }
    final parts = start.split(':');
    final time = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    ).format(context);
    return 'Every ${medicine.intervalHours}h from $time';
  }

  String _foodTimingLabel(String value) => switch (value) {
    'before_food' => 'Before food',
    'after_food' => 'After food',
    'with_food' => 'With food',
    'empty_stomach' => 'Empty stomach',
    'anytime' => 'Any time',
    _ => 'As directed',
  };
}
