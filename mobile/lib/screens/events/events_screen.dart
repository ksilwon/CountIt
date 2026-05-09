import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> _events = [];
  bool _loading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _events = await EventService.getEvents(category: _selectedCategory);
    setState(() => _loading = false);
  }

  Widget _buildList(List<Event> list) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (list.isEmpty) return const Center(child: Text('Brak wydarzeń', style: TextStyle(color: Colors.grey)));
    
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        itemBuilder: (ctx, i) {
          final e = list[i];
          return Card(
            child: ListTile(
              leading: Text(categoryEmoji[e.category] ?? '📦', style: const TextStyle(fontSize: 28)),
              title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${e.amount.toStringAsFixed(2)} PLN · ${e.createdBy.name}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('÷${e.splitAmount.toStringAsFixed(2)} PLN', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
                  if (e.isSettled)
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: e.id)),
              ).then((_) => _load()),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeEvents = _events.where((e) => !e.isSettled).toList();
    final settledEvents = _events.where((e) => e.isSettled).toList();

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Filtry kategorii
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _categoryChip(null, '🔍 Wszystkie'),
                  ...categoryEmoji.entries.map((e) => _categoryChip(e.key, '${e.value} ${e.key}')),
                ],
              ),
            ),
            const TabBar(
              tabs: [
                Tab(text: 'Aktywne'),
                Tab(text: 'Rozliczone'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(activeEvents),
                  _buildList(settledEvents),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventScreen())).then((_) => _load()),
        icon: const Icon(Icons.add),
        label: const Text('Nowe wydarzenie'),
      ),
    );
  }

  Widget _categoryChip(String? cat, String label) {
    final selected = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _selectedCategory = cat);
          _load();
        },
      ),
    );
  }
}
