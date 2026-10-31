import 'package:flutter/material.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/fever/presentation/fever_entry_sheet.dart';

class FeverTrackerPage extends StatefulWidget {
  const FeverTrackerPage({super.key, required this.repository});
  final FeverRepository repository;

  @override
  State<FeverTrackerPage> createState() => _FeverTrackerPageState();
}

class _FeverTrackerPageState extends State<FeverTrackerPage> {
  List<FeverEntry> _entries = const [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  TemperatureUnit _unit = TemperatureUnit.celsius;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.favorite, color: theme.colorScheme.onPrimary),
            ),
            const SizedBox(width: 12),
            const Text('MediMate'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadEntries,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addEntryButton'),
        onPressed: _saving ? null : () => _openEntrySheet(),
        icon: const Icon(Icons.add),
        label: const Text('Add reading'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadEntries,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              sliver: SliverList.list(
                children: [
                  Text(
                    'Fever tracker',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Keep a simple timeline of temperature and symptoms.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SegmentedButton<TemperatureUnit>(
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
                      onSelectionChanged: (selection) {
                        setState(() => _unit = selection.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SummaryCard(entry: _entries.firstOrNull, unit: _unit),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'History',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_entries.isNotEmpty)
                        Text(
                          '${_entries.length} ${_entries.length == 1 ? 'entry' : 'entries'}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    _ErrorCard(message: _error!, onRetry: _loadEntries)
                  else if (_entries.isEmpty)
                    const _EmptyState()
                  else
                    ..._entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EntryCard(
                          entry: entry,
                          unit: _unit,
                          onEdit: () => _openEntrySheet(entry),
                          onDelete: () => _confirmDelete(entry),
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

  Future<void> _loadEntries() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final entries = await widget.repository.listEntries();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not reach MediMate. Make sure the FastAPI backend is running.';
      });
    }
  }

  Future<void> _openEntrySheet([FeverEntry? entry]) async {
    final input = await showModalBottomSheet<FeverEntryInput>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder: (_) => FeverEntrySheet(initial: entry, initialUnit: _unit),
    );
    if (input == null || !mounted) return;
    setState(() => _saving = true);
    try {
      if (entry == null) {
        await widget.repository.createEntry(input);
      } else {
        await widget.repository.updateEntry(entry.id, input);
      }
      await _loadEntries();
      if (mounted) {
        _showMessage(entry == null ? 'Reading saved' : 'Reading updated');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not save the reading. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _confirmDelete(FeverEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this reading?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.repository.deleteEntry(entry.id);
      await _loadEntries();
      if (mounted) _showMessage('Reading deleted');
    } catch (_) {
      if (mounted) _showMessage('Could not delete the reading.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.entry, required this.unit});
  final FeverEntry? entry;
  final TemperatureUnit unit;

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
                    entry == null ? 'No readings yet' : 'Latest reading',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry == null
                        ? 'Add your first temperature'
                        : _formatTemperature(entry!.temperatureC, unit),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (entry != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(context, entry!.measuredAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
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

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.unit,
    required this.onEdit,
    required this.onDelete,
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
                _formatTemperature(entry.temperatureC, unit),
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
                    _formatDateTime(context, entry.measuredAt),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _methodLabel(entry.measurementMethod),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
        child: Column(
          children: [
            Icon(
              Icons.monitor_heart_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              'No fever readings yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap “Add reading” to start your timeline.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 38),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(BuildContext context, DateTime date) {
  final time = TimeOfDay.fromDateTime(date).format(context);
  return '${date.day}/${date.month}/${date.year} · $time';
}

String _methodLabel(String method) => switch (method) {
  'oral' => 'Oral measurement',
  'axillary' => 'Underarm measurement',
  'tympanic' => 'Ear measurement',
  'temporal' => 'Forehead measurement',
  'rectal' => 'Rectal measurement',
  _ => 'Other measurement',
};

String _formatTemperature(double celsius, TemperatureUnit unit) {
  if (unit == TemperatureUnit.fahrenheit) {
    final fahrenheit = (celsius * 9 / 5) + 32;
    return '${fahrenheit.toStringAsFixed(1)}°F';
  }
  return '${celsius.toStringAsFixed(1)}°C';
}
