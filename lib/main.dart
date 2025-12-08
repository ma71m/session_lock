import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'providers/session_provider.dart';
import 'providers/permission_provider.dart';
import 'services/storage_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SessionLockApp());
}

class SessionLockApp extends StatelessWidget {
  const SessionLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
      ],
      child: MaterialApp(
        title: 'SessionLock',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const _InitialScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _InitialScreen extends StatefulWidget {
  const _InitialScreen();

  @override
  State<_InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<_InitialScreen> {
  final StorageService _storage = StorageService();
  bool _isLoading = true;
  bool _onboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Check onboarding status
    final onboardingComplete = await _storage.isOnboardingComplete();

    // Initialize providers
    final settingsProvider = context.read<SettingsProvider>();
    final sessionProvider = context.read<SessionProvider>();
    final permissionProvider = context.read<PermissionProvider>();

    await settingsProvider.initialize();
    await sessionProvider.initialize(settingsProvider.settings);
    await permissionProvider.checkPermissions();

    setState(() {
      _onboardingComplete = onboardingComplete;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _onboardingComplete
        ? const DashboardScreen()
        : const OnboardingScreen();
  }
}
