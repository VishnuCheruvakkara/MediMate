import 'package:flutter/material.dart';
import 'package:medimate/core/widgets/app_brand_title.dart';
import 'package:medimate/features/auth/data/auth_api_repository.dart';
import 'package:medimate/features/auth/domain/auth_repository.dart';
import 'package:medimate/features/auth/domain/auth_user.dart';
import 'package:medimate/features/auth/presentation/login_signup_page.dart';
import 'package:medimate/features/auth/presentation/onboarding_page.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/fever/presentation/fever_tracker_page.dart';
import 'package:medimate/features/medicines/domain/medicine.dart';
import 'package:medimate/features/medicines/presentation/medicine_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.medicineRepository,
    required this.feverRepository,
    this.authRepository,
    this.initialIndex = 0,
  });

  final MedicineRepository medicineRepository;
  final FeverRepository feverRepository;
  final AuthRepository? authRepository;
  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _authRepository = widget.authRepository ?? AuthApiRepository();
  }

  Future<void> _openAccountSheet(BuildContext context) async {
    final user = await _authRepository.getCurrentUser();
    if (!context.mounted) return;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        final theme = Theme.of(bottomSheetContext);
        final isGuest = user == null;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        isGuest ? Icons.person_outline : Icons.person,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGuest ? 'Guest User' : (user.name.isEmpty ? 'Account' : user.name),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isGuest ? 'Offline profile mode' : user.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (isGuest)
                  FilledButton.icon(
                    key: const Key('accountLoginButton'),
                    onPressed: () {
                      Navigator.of(bottomSheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LoginSignupPage(
                            authRepository: _authRepository,
                            medicineRepository: widget.medicineRepository,
                            feverRepository: widget.feverRepository,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In or Register'),
                  )
                else
                  OutlinedButton.icon(
                    key: const Key('accountLogoutButton'),
                    onPressed: () async {
                      await _authRepository.logout();
                      if (!bottomSheetContext.mounted) return;
                      Navigator.of(bottomSheetContext).pop();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => OnboardingPage(
                            authRepository: _authRepository,
                            medicineRepository: widget.medicineRepository,
                            feverRepository: widget.feverRepository,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBrandTitle(),
        actions: [
          IconButton(
            key: const Key('accountProfileButton'),
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile & Account',
            onPressed: () => _openAccountSheet(context),
          ),
        ],
      ),
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
