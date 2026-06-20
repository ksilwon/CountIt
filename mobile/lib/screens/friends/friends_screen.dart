import 'package:flutter/material.dart';
import '../../config/app_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

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

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
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

  Widget _friendTile(String name, String email, {Widget? trailing}) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          UserAvatar(name: name),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PillTabBar(
          controller: _tab,
          tabs: [
            'Znajomi (${_friends.length})',
            'Zaproszenia (${_pending.length})',
            'Szukaj',
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _friends.isEmpty
                      ? const EmptyState(
                          icon: Icons.people_outline,
                          title: 'Brak znajomych',
                          subtitle: 'Wyszukaj użytkowników w zakładce Szukaj',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _friends.length,
                          itemBuilder: (_, i) => _friendTile(
                            _friends[i]['name'] ?? '',
                            _friends[i]['email'] ?? '',
                          ),
                        ),
              _pending.isEmpty
                  ? const EmptyState(
                      icon: Icons.mail_outline,
                      title: 'Brak zaproszeń',
                      subtitle: 'Nowe zaproszenia pojawią się tutaj',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pending.length,
                      itemBuilder: (_, i) {
                        final req = _pending[i];
                        return _friendTile(
                          req['requester']?['name'] ?? '',
                          req['requester']?['email'] ?? '',
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                            onPressed: () async {
                              await FriendService.acceptRequest(req['_id']);
                              _load();
                            },
                          ),
                        );
                      },
                    ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Wyszukaj po imieniu lub emailu...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onChanged: _search,
                    ),
                  ),
                  Expanded(
                    child: _searchResults.isEmpty
                        ? const EmptyState(
                            icon: Icons.search_rounded,
                            title: 'Wyszukaj znajomych',
                            subtitle: 'Wpisz min. 2 znaki',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _searchResults.length,
                            itemBuilder: (_, i) {
                              final u = _searchResults[i];
                              return _friendTile(
                                u['name'] ?? '',
                                u['email'] ?? '',
                                trailing: IconButton(
                                  icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
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
    );
  }
}
