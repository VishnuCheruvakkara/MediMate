import 'package:flutter/material.dart';
import 'package:medimate/core/widgets/app_brand_title.dart';
import 'package:medimate/core/widgets/app_confirm_dialog.dart';
import 'package:medimate/core/widgets/app_empty_state.dart';
import 'package:medimate/core/widgets/app_error_state.dart';
import 'package:medimate/core/widgets/app_loading_state.dart';
import 'package:medimate/core/widgets/app_page_header.dart';
import 'package:medimate/core/widgets/app_section_header.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/fever/presentation/fever_entry_card.dart';
import 'package:medimate/features/fever/presentation/fever_entry_sheet.dart';
import 'package:medimate/features/fever/presentation/fever_summary_card.dart';

class FeverTrackerPage extends StatefulWidget {
  const FeverTrackerPage({
    super.key,
    required this.repository,
    this.showAppBar = true,
  });
  final FeverRepository repository;
  final bool showAppBar;

  @override
  State<FeverTrackerPage> createState() => _FeverTrackerPageState();
}

class _FeverTrackerPageState extends State<FeverTrackerPage> {
  List<FeverEntry> _entries = const [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const AppBrandTitle(),
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: _loading ? null : _loadEntries,
                  icon: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
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
                  const AppPageHeader(
                    title: 'Fever tracker',
                    description:
                        'Keep a simple timeline of temperature and symptoms.',
                  ),
                  const SizedBox(height: 22),
                  FeverSummaryCard(entry: _entries.firstOrNull),
                  const SizedBox(height: 26),
                  AppSectionHeader(
                    title: 'History',
                    trailing: _entries.isEmpty
                        ? null
                        : Text(
                            '${_entries.length} ${_entries.length == 1 ? 'entry' : 'entries'}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const AppLoadingState()
                  else if (_error != null)
                    AppErrorState(message: _error!, onRetry: _loadEntries)
                  else if (_entries.isEmpty)
                    const AppEmptyState(
                      icon: Icons.monitor_heart_outlined,
                      title: 'No fever readings yet',
                      message: 'Tap “Add reading” to start your timeline.',
                    )
                  else
                    ..._entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FeverEntryCard(
                          entry: entry,
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
      builder: (_) => FeverEntrySheet(initial: entry),
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
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Delete this reading?',
      message: 'This action cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;
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
