import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'app_selection_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SessionLock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Expanded(
                child: _TimerDisplay(),
              ),
              const SizedBox(height: 32),
              const _MonitoringToggle(),
              const SizedBox(height: 24),
              const _PresetButtons(),
              const SizedBox(height: 32),
              _QuickActionsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  const _TimerDisplay();

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, _) {
        final state = sessionProvider.state;
        final isActive = state.isSessionActive;
        final displayTime = isActive
            ? state.formattedSessionTime
            : state.formattedInactivityTime;
        final label = isActive ? 'Session Time' : 'Break Time';
        final color = state.isBlocked ? AppTheme.error : AppTheme.primary;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              displayTime,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: color,
                  ),
            ),
            if (state.isBlocked) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'BLOCKED',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.error,
                      ),
                ),
              ),
            ],
            if (state.currentApp != null) ...[
              const SizedBox(height: 16),
              Text(
                'Currently using: ${state.currentApp}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MonitoringToggle extends StatelessWidget {
  const _MonitoringToggle();

  @override
  Widget build(BuildContext context) {
    return Consumer2<SessionProvider, SettingsProvider>(
      builder: (context, sessionProvider, settingsProvider, _) {
        final isMonitoring = settingsProvider.settings.isMonitoring;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitoring',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMonitoring ? 'Active' : 'Inactive',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Switch(
                  value: isMonitoring,
                  onChanged: (value) async {
                    if (value) {
                      await sessionProvider
                          .startMonitoring(settingsProvider.settings);
                      await settingsProvider.setMonitoring(true);
                    } else {
                      await sessionProvider.stopMonitoring();
                      await settingsProvider.setMonitoring(false);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PresetButtons extends StatelessWidget {
  const _PresetButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _PresetButton(
                label: '20/10',
                sessionMin: 20,
                breakMin: 10,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _PresetButton(
                label: '25/5',
                sessionMin: 25,
                breakMin: 5,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _PresetButton(
                label: '30/15',
                sessionMin: 30,
                breakMin: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final int sessionMin;
  final int breakMin;

  const _PresetButton({
    required this.label,
    required this.sessionMin,
    required this.breakMin,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final isActive =
            settingsProvider.settings.sessionDuration == sessionMin &&
                settingsProvider.settings.breakDuration == breakMin;

        return OutlinedButton(
          onPressed: () => settingsProvider.applyPreset(sessionMin, breakMin),
          style: OutlinedButton.styleFrom(
            backgroundColor:
                isActive ? AppTheme.primary.withOpacity(0.1) : null,
            side: BorderSide(
              color: isActive ? AppTheme.primary : Colors.grey.shade300,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Text(label),
        );
      },
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.apps, color: AppTheme.primary),
              title: const Text('Select Apps'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AppSelectionScreen()),
                );
              },
            ),
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, _) {
                return ListTile(
                  leading: const Icon(Icons.timer, color: AppTheme.primary),
                  title: const Text('Session / Break'),
                  subtitle: Text(
                    '${settingsProvider.settings.sessionDuration}min / ${settingsProvider.settings.breakDuration}min',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
