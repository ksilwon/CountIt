import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _balanceAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(parent: _balanceAnimController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _balanceAnimController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _balanceAnimController, curve: Curves.elasticOut),
    );
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
    if (_loading) return const Center(child: CircularProgressIndicator());

    final balance = _dashboardData['balance'] ?? {};
    final iOwe = (balance['iOwe'] ?? 0.0).toDouble();
    final owedToMe = (balance['owedToMe'] ?? 0.0).toDouble();
    final net = (balance['net'] ?? 0.0).toDouble();
    final fmt = NumberFormat.currency(locale: 'pl_PL', symbol: 'PLN');
    final recentEvents = _dashboardData['recentEvents'] as List<dynamic>? ?? [];
    final isPositive = net >= 0;

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPositive
                          ? [const Color(0xFF00BFA6), const Color(0xFF00897B)]
                          : [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (isPositive ? const Color(0xFF00BFA6) : const Color(0xFFFF6B6B))
                            .withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isPositive ? Icons.trending_up : Icons.trending_down,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Twój bilans',
                              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isPositive ? '+${fmt.format(net)}' : fmt.format(net),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _balanceStat('Jesteś winien', fmt.format(iOwe), Icons.arrow_upward),
                            ),
                            Container(width: 1, height: 40, color: Colors.white24),
                            Expanded(
                              child: _balanceStat('Należy Ci się', fmt.format(owedToMe), Icons.arrow_downward),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ostatnie wydarzenia', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 1),
                child: const Text('Zobacz wszystkie'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentEvents.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text('Brak wydarzeń', style: TextStyle(color: Colors.grey.shade500)),
                ),
              ),
            )
          else
            ...recentEvents.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + i * 100),
                curve: Curves.easeOut,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _categoryEmoji(e['category'] ?? 'inne'),
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    title: Text(e['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${e['amount']} PLN · ${e['createdBy']?['name'] ?? ''}'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _balanceStat(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  String _categoryEmoji(String cat) {
    const map = {
      'jedzenie': '🍕',
      'transport': '🚗',
      'mieszkanie': '🏠',
      'rozrywka': '🎉',
      'zakupy': '🛒',
      'podroze': '✈️',
    };
    return map[cat] ?? '📦';
  }

  String _appBarTitle(int index, String? name) {
    switch (index) {
      case 0:
        return 'Cześć, ${name ?? ''}! 👋';
      case 1:
        return 'Wydarzenia';
      case 2:
        return 'Znajomi';
      default:
        return 'Profil';
    }
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
        title: Text(_appBarTitle(_selectedIndex, user?.name)),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (!mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            ),
        ],
      ),
      body: tabs[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Wydarzenia'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Znajomi'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
