import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Rules',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const _SessionDurationSetting(),
                  const SizedBox(height: 16),
                  const _BreakDurationSetting(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advanced',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const _StrictModeSetting(),
                  const Divider(),
                  const _EmergencyBypassSetting(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('How it works'),
                    subtitle: const Text('Learn about SessionLock'),
                    onTap: () {
                      _showHowItWorksDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHowItWorksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How SessionLock Works'),
        content: const SingleChildScrollView(
          child: Text(
            'SessionLock monitors your usage of selected social media apps.\n\n'
            '• Session Timer: Tracks time spent in tracked apps\n'
            '• Break Timer: Tracks time away from tracked apps\n'
            '• When session time reaches the limit, apps are blocked\n'
            '• Apps remain blocked until you take a full break\n'
            '• After a complete break, the session timer resets\n\n'
            'This helps you maintain healthy social media habits.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _SessionDurationSetting extends StatelessWidget {
  const _SessionDurationSetting();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final duration = settingsProvider.settings.sessionDuration;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Session Duration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$duration min',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: duration.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              label: '$duration min',
              onChanged: (value) {
                settingsProvider.setSessionDuration(value.toInt());
              },
            ),
            Text(
              'Maximum time in tracked apps before blocking',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        );
      },
    );
  }
}

class _BreakDurationSetting extends StatelessWidget {
  const _BreakDurationSetting();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final duration = settingsProvider.settings.breakDuration;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Break Duration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$duration min',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: duration.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              label: '$duration min',
              onChanged: (value) {
                settingsProvider.setBreakDuration(value.toInt());
              },
            ),
            Text(
              'Required time away from apps to reset session',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        );
      },
    );
  }
}

class _StrictModeSetting extends StatelessWidget {
  const _StrictModeSetting();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return SwitchListTile(
          title: const Text('Strict Mode'),
          subtitle: const Text('Harder to bypass blocking (experimental)'),
          value: settingsProvider.settings.strictMode,
          onChanged: (_) => settingsProvider.toggleStrictMode(),
        );
      },
    );
  }
}

class _EmergencyBypassSetting extends StatelessWidget {
  const _EmergencyBypassSetting();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return SwitchListTile(
          title: const Text('Allow Emergency Bypass'),
          subtitle: const Text('Enable PIN/biometric override'),
          value: settingsProvider.settings.allowEmergencyBypass,
          onChanged: (_) => settingsProvider.toggleEmergencyBypass(),
        );
      },
    );
  }
}
