import 'package:flutter/material.dart';
import 'package:medimate/app/home_shell.dart';
import 'package:medimate/core/widgets/app_brand_title.dart';
import 'package:medimate/features/auth/presentation/login_signup_page.dart';
import 'package:medimate/features/fever/data/fever_api_repository.dart';
import 'package:medimate/features/medicines/data/medicine_api_repository.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: AppBrandTitle()),
              const SizedBox(height: 12),
              Text(
                'Your calm, offline-first medicine reminder and health companion',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              _FeatureTile(
                icon: Icons.medication_outlined,
                title: 'Medicine Schedules',
                subtitle: 'Organize prescriptions, repeat intervals, and dose times.',
              ),
              const SizedBox(height: 16),
              _FeatureTile(
                icon: Icons.thermostat_outlined,
                title: 'Fever & Symptom Log',
                subtitle: 'Accurately record temperature with clinical context.',
              ),
              const SizedBox(height: 16),
              _FeatureTile(
                icon: Icons.offline_bolt_outlined,
                title: 'Works Offline',
                subtitle: 'Keep tracking your health records even without internet.',
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginSignupPage(),
                    ),
                  );
                },
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Direct preview access into HomeShell
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => HomeShell(
                        medicineRepository: MedicineApiRepository(),
                        feverRepository: FeverApiRepository(),
                      ),
                    ),
                  );
                },
                child: const Text('Continue as Guest'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

