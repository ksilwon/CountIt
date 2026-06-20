import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_palette.dart';
import 'config/app_styles.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'widgets/glass_surface.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const CountItApp(),
    ),
  );
}

class CountItApp extends StatelessWidget {
  const CountItApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'CountIt',
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeProvider.materialThemeMode,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();

        return Stack(
          fit: StackFit.expand,
          children: [
            MeshGradientBackground(brightness: Theme.of(context).brightness),
            child,
          ],
        );
      },
      home: const _SplashRouter(),
    );
  }
}

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    await context.read<AuthProvider>().tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final palette = context.palette;

    if (auth.isInitializing) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.card,
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 24),
              Text('CountIt', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('Ładowanie...', style: TextStyle(color: palette.textSecondary)),
              const SizedBox(height: 28),
              const CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      );
    }

    return auth.isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}
