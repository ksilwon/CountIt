import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_styles.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/glass_surface.dart';
import '../auth/login_screen.dart';
import '../events/events_screen.dart';
import '../friends/friends_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  Map<String, dynamic> _dashboardData = {};
  bool _loading = true;

  late AnimationController _balanceAnimController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _balanceAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnimation = CurvedAnimation(parent: _balanceAnimController, curve: Curves.easeOutCubic);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(_fadeAnimation);
    _loadDashboard();
  }

  @override
  void dispose() {
    _balanceAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    _balanceAnimController.reset();
    final data = await DashboardService.getDashboard();
    if (!mounted) return;
    setState(() {
      _dashboardData = data;
      _loading = false;
    });
    _balanceAnimController.forward();
  }

  Widget _buildDashboardTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final balance = _dashboardData['balance'] ?? {};
    final iOwe = (balance['iOwe'] ?? 0.0).toDouble();
    final owedToMe = (balance['owedToMe'] ?? 0.0).toDouble();
    final net = (balance['net'] ?? 0.0).toDouble();
    final fmt = NumberFormat.currency(locale: 'pl_PL', symbol: 'zł');
    final recentEvents = _dashboardData['recentEvents'] as List<dynamic>? ?? [];
    final isPositive = net >= 0;
    final isZero = net.abs() < 0.01;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.cardDark, AppColors.cardDarkEnd],
                    ),
                    boxShadow: AppShadows.card,
                  ),
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isZero) ...[
                            const Text(
                              'Twój bilans',
                              style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                          ],
                          Text(
                            isZero
                                ? '----'
                                : (isPositive ? '+${fmt.format(net)}' : fmt.format(net)),
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: _miniStat('Winien', fmt.format(iOwe), AppColors.error)),
                              Container(width: 1, height: 36, color: Colors.white12),
                              Expanded(child: _miniStat('Należy się', fmt.format(owedToMe), AppColors.accent)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Ostatnie wydarzenia',
            actionLabel: 'Wszystkie',
            onAction: () => setState(() => _selectedIndex = 1),
          ),
          const SizedBox(height: 12),
          if (recentEvents.isEmpty)
            const AppCard(
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Brak wydarzeń',
                subtitle: 'Utwórz pierwsze wydarzenie w zakładce Wydarzenia',
              ),
            )
          else
            ...recentEvents.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 350 + i * 80),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
                ),
                child: AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  onTap: () => setState(() => _selectedIndex = 1),
                  child: Row(
                    children: [
                      CategoryBadge(category: e['category'] ?? 'inne', size: 46),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e['title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${e['amount']} zł · ${e['createdBy']?['name'] ?? ''}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _appBarTitle(int index, String? name) {
    switch (index) {
      case 0:
        return 'Witaj, ${name?.split(' ').first ?? ''}';
      case 1:
        return 'Wydarzenia';
      case 2:
        return 'Znajomi';
      default:
        return 'Profil';
    }
  }

  String? _appBarSubtitle(int index) {
    if (index == 0) return 'Oto podsumowanie Twoich rozliczeń';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final tabs = [
      _buildDashboardTab(),
      const EventsScreen(),
      const FriendsScreen(),
      ProfileScreen(user: user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_appBarTitle(_selectedIndex, user?.name)),
            if (_appBarSubtitle(_selectedIndex) != null)
              Text(
                _appBarSubtitle(_selectedIndex)!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
              ),
          ],
        ),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Wyloguj',
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (!mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            ),
        ],
      ),
      body: tabs[_selectedIndex],
      bottomNavigationBar: GlassNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Wydarzenia'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people_rounded), label: 'Znajomi'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}
