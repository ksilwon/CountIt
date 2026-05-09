import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<dynamic> _friends = [];
  List<dynamic> _pending = [];
  List<dynamic> _searchResults = [];
  final _searchCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final friends = await FriendService.getFriends();
    final pending = await FriendService.getPendingRequests();
    setState(() {
      _friends = friends;
      _pending = pending;
      _loading = false;
    });
  }

  Future<void> _search(String q) async {
    if (q.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    final results = await FriendService.searchUsers(q);
    setState(() => _searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tab,
            tabs: [
              Tab(text: 'Znajomi (${_friends.length})'),
              Tab(text: 'Zaproszenia (${_pending.length})'),
              const Tab(text: 'Szukaj'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // Znajomi
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _friends.isEmpty
                        ? const Center(child: Text('Brak znajomych'))
                        : ListView.builder(
                            itemCount: _friends.length,
                            itemBuilder: (_, i) => ListTile(
                              leading: CircleAvatar(child: Text(_friends[i]['name']?[0] ?? '?')),
                              title: Text(_friends[i]['name'] ?? ''),
                              subtitle: Text(_friends[i]['email'] ?? ''),
                            ),
                          ),
                // Oczekujące zaproszenia
                _pending.isEmpty
                    ? const Center(child: Text('Brak oczekujących zaproszeń'))
                    : ListView.builder(
                        itemCount: _pending.length,
                        itemBuilder: (_, i) {
                          final req = _pending[i];
                          return ListTile(
                            leading: CircleAvatar(child: Text(req['requester']?['name']?[0] ?? '?')),
                            title: Text(req['requester']?['name'] ?? ''),
                            subtitle: Text(req['requester']?['email'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () async {
                                await FriendService.acceptRequest(req['_id']);
                                _load();
                              },
                            ),
                          );
                        },
                      ),
                // Szukaj
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Wyszukaj po imieniu lub emailu...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: _search,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (_, i) {
                          final u = _searchResults[i];
                          return ListTile(
                            leading: CircleAvatar(child: Text(u['name']?[0] ?? '?')),
                            title: Text(u['name'] ?? ''),
                            subtitle: Text(u['email'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_add),
                              onPressed: () async {
                                final res = await FriendService.sendRequest(u['_id']);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(res['success'] == true ? 'Zaproszenie wysłane!' : res['message'] ?? 'Błąd')),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
