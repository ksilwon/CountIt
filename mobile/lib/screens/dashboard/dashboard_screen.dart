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

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic> _dashboardData = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    final data = await DashboardService.getDashboard();
    setState(() {
      _dashboardData = data;
      _loading = false;
    });
  }

  Widget _buildDashboardTab() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final balance = _dashboardData['balance'] ?? {};
    final iOwe = (balance['iOwe'] ?? 0.0).toDouble();
    final owedToMe = (balance['owedToMe'] ?? 0.0).toDouble();
    final net = (balance['net'] ?? 0.0).toDouble();
    final fmt = NumberFormat.currency(locale: 'pl_PL', symbol: 'PLN');
    final recentEvents = _dashboardData['recentEvents'] as List<dynamic>? ?? [];

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bilans card
          Card(
            color: net >= 0 ? Colors.green.shade50 : Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Twój bilans', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(
                    net >= 0 ? '+${fmt.format(net)}' : fmt.format(net),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: net >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: [
                        const Text('Jesteś winien', style: TextStyle(color: Colors.grey)),
                        Text(fmt.format(iOwe), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ]),
                      Column(children: [
                        const Text('Należy Ci się', style: TextStyle(color: Colors.grey)),
                        Text(fmt.format(owedToMe), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Ostatnie wydarzenia', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (recentEvents.isEmpty)
            const Center(child: Text('Brak wydarzeń', style: TextStyle(color: Colors.grey)))
          else
            ...recentEvents.map((e) => Card(
                  child: ListTile(
                    leading: Text(
                      _categoryEmoji(e['category'] ?? 'inne'),
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(e['title'] ?? ''),
                    subtitle: Text('${e['amount']} PLN · ${e['createdBy']?['name'] ?? ''}'),
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                )),
        ],
      ),
    );
  }

  String _categoryEmoji(String cat) {
    const map = {'jedzenie': '🍕', 'transport': '🚗', 'mieszkanie': '🏠', 'rozrywka': '🎉', 'zakupy': '🛒', 'podroze': '✈️'};
    return map[cat] ?? '📦';
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
        title: Text(_selectedIndex == 0
            ? 'Cześć, ${user?.name ?? ''}! 👋'
            : _selectedIndex == 1
                ? 'Wydarzenia'
                : _selectedIndex == 2
                    ? 'Znajomi'
                    : 'Profil'),
        actions: [
          if (_selectedIndex == 0)
            IconButton(icon: const Icon(Icons.logout), onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            }),
        ],
      ),
      body: tabs[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Wydarzenia'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Znajomi'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
