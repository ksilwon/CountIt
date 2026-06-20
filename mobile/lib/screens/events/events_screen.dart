import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';
import 'events_map_tab.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> _events = [];
  bool _loading = true;
  String? _selectedCategory;
  bool _isGridView = false;

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

  void _openDetail(Event e) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: e.id)),
    ).then((_) => _load());
  }

  Widget _buildList(List<Event> list) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('Brak wydarzeń', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: _isGridView ? _buildGrid(list) : _buildListView(list),
    );
  }

  Widget _buildListView(List<Event> list) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (ctx, i) => _buildListTile(list[i]),
    );
  }

  Widget _buildGrid(List<Event> list) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) => _buildGridTile(list[i]),
    );
  }

  Widget _buildListTile(Event e) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetail(e),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(categoryEmoji[e.category] ?? '📦', style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      '${e.amount.toStringAsFixed(2)} PLN · ${e.createdBy.name}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 2),
                        Text(e.locationName, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '÷${e.splitAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const Text('PLN/os.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  if (e.isSettled)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.check_circle, color: Colors.green, size: 18),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridTile(Event e) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetail(e),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(categoryEmoji[e.category] ?? '📦', style: const TextStyle(fontSize: 28)),
                  if (e.isSettled) const Icon(Icons.check_circle, color: Colors.green, size: 18),
                ],
              ),
              const Spacer(),
              Text(
                e.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                '${e.amount.toStringAsFixed(2)} PLN',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
              ),
              Text(
                e.locationName,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeEvents = _events.where((e) => !e.isSettled).toList();
    final settledEvents = _events.where((e) => e.isSettled).toList();

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _categoryChip(null, '🔍 Wszystkie'),
                          ...categoryEmoji.entries.map((e) => _categoryChip(e.key, '${e.value} ${e.key}')),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: _isGridView ? 'Widok listy' : 'Widok siatki',
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: Tween<double>(begin: 0.75, end: 1).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Icon(
                        _isGridView ? Icons.view_list : Icons.grid_view,
                        key: ValueKey(_isGridView),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: [
                Tab(text: 'Aktywne (${activeEvents.length})'),
                Tab(text: 'Rozliczone (${settledEvents.length})'),
                const Tab(text: 'Mapa'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(activeEvents),
                  _buildList(settledEvents),
                  EventsMapTab(events: _events, loading: _loading, onRefresh: _load),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateEventScreen()),
        ).then((_) => _load()),
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
        label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : null)),
        selected: selected,
        selectedColor: Theme.of(context).colorScheme.primary,
        checkmarkColor: Colors.white,
        onSelected: (_) {
          setState(() => _selectedCategory = cat);
          _load();
        },
      ),
    );
  }
}
