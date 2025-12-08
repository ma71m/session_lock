import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_info.dart';
import '../providers/settings_provider.dart';
import '../services/platform_service.dart';
import '../theme/app_theme.dart';
import 'dart:convert';
import 'dart:typed_data';

class AppSelectionScreen extends StatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  final PlatformService _platform = PlatformService();
  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Suggested apps
  final List<String> _suggestedPackages = [
    'com.facebook.katana',
    'com.instagram.android',
    'com.whatsapp',
    'com.zhiliaoapp.musically', // TikTok
    'com.twitter.android',
    'com.snapchat.android',
  ];

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    setState(() => _isLoading = true);

    final apps = await _platform.getInstalledApps();
    final settingsProvider = context.read<SettingsProvider>();

    // Mark tracked apps
    final trackedApps = apps.map((app) {
      return app.copyWith(
        isTracked: settingsProvider.isAppTracked(app.packageName),
      );
    }).toList();

    setState(() {
      _allApps = trackedApps;
      _filteredApps = trackedApps;
      _isLoading = false;
    });
  }

  void _filterApps(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredApps = _allApps;
      } else {
        _filteredApps = _allApps
            .where((app) =>
                app.appName.toLowerCase().contains(query.toLowerCase()) ||
                app.packageName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  List<AppInfo> get _suggestedApps {
    return _allApps
        .where((app) => _suggestedPackages.contains(app.packageName))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Apps'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search apps...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterApps,
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  if (_suggestedApps.isNotEmpty && _searchQuery.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Suggested Apps',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                      ),
                    ),
                    ..._suggestedApps.map((app) => _AppTile(app: app)),
                    const Divider(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'All Apps',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                      ),
                    ),
                  ],
                  ..._filteredApps.map((app) => _AppTile(app: app)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final AppInfo app;

  const _AppTile({required this.app});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final isTracked = settingsProvider.isAppTracked(app.packageName);

        return ListTile(
          leading: _buildAppIcon(),
          title: Text(app.appName),
          subtitle: Text(
            app.packageName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textHint,
                ),
          ),
          trailing: Checkbox(
            value: isTracked,
            onChanged: (value) {
              if (value == true) {
                settingsProvider.addTrackedApp(app.packageName);
              } else {
                settingsProvider.removeTrackedApp(app.packageName);
              }
            },
          ),
          onTap: () {
            if (isTracked) {
              settingsProvider.removeTrackedApp(app.packageName);
            } else {
              settingsProvider.addTrackedApp(app.packageName);
            }
          },
        );
      },
    );
  }

  Widget _buildAppIcon() {
    if (app.iconBase64 != null) {
      try {
        final bytes = base64Decode(app.iconBase64!);
        return Image.memory(
          Uint8List.fromList(bytes),
          width: 40,
          height: 40,
        );
      } catch (e) {
        return const Icon(Icons.apps, size: 40);
      }
    }
    return const Icon(Icons.apps, size: 40);
  }
}
