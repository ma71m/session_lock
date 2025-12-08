import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/permission_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await context.read<PermissionProvider>().checkPermissions();
  }

  Future<void> _completeOnboarding() async {
    await _storage.setOnboardingComplete(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Welcome to\nSessionLock',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Take control of your social media usage',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 48),
              Text(
                'Required Permissions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<PermissionProvider>(
                  builder: (context, permProvider, _) {
                    return ListView(
                      children: [
                        _PermissionCard(
                          title: 'Usage Access',
                          description:
                              'Required to detect which apps you\'re using',
                          isGranted: permProvider.hasUsageStats,
                          onRequest: () => permProvider.requestUsageStats(),
                        ),
                        const SizedBox(height: 12),
                        _PermissionCard(
                          title: 'Display Over Other Apps',
                          description: 'Required to show blocking screen',
                          isGranted: permProvider.hasOverlay,
                          onRequest: () => permProvider.requestOverlay(),
                        ),
                        const SizedBox(height: 12),
                        _PermissionCard(
                          title: 'Notifications',
                          description: 'Required for monitoring service',
                          isGranted: permProvider.hasNotification,
                          onRequest: () => permProvider.requestNotification(),
                        ),
                        const SizedBox(height: 12),
                        _PermissionCard(
                          title: 'Battery Optimization',
                          description: 'Recommended to keep monitoring active',
                          isGranted: permProvider.hasBatteryOptimization,
                          onRequest: () =>
                              permProvider.requestBatteryOptimization(),
                          optional: true,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Consumer<PermissionProvider>(
                builder: (context, permProvider, _) {
                  final canContinue = permProvider.allPermissionsGranted;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canContinue ? _completeOnboarding : null,
                      child: const Text('Continue'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onRequest;
  final bool optional;

  const _PermissionCard({
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onRequest,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isGranted ? Icons.check_circle : Icons.circle_outlined,
              color: isGranted ? AppTheme.success : AppTheme.textHint,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (optional) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Optional',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textHint,
                                  ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (!isGranted)
              TextButton(
                onPressed: onRequest,
                child: const Text('Grant'),
              ),
          ],
        ),
      ),
    );
  }
}
