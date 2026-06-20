import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const CountItApp(),
    ),
  );
}

class CountItApp extends StatelessWidget {
  const CountItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CountIt',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
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
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await context.read<AuthProvider>().tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                const Color(0xFFF5F6FA),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('CountIt', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: -1)),
                SizedBox(height: 8),
                Text('Dziel wydatki w grupie', style: TextStyle(color: Colors.grey, fontSize: 15)),
                SizedBox(height: 32),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );
    }

    return auth.isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}
