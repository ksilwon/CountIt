import 'package:flutter/material.dart';
import '../../config/app_palette.dart';
import '../../config/app_styles.dart';
import '../../models/event.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';
import '../../widgets/common_widgets.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';
import 'events_map_tab.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  List<Event> _events = [];
  bool _loading = true;
  String? _selectedCategory;
  bool _isGridView = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (list.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Brak wydarzeń',
        subtitle: 'Naciśnij + aby dodać nowe wydarzenie',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: _isGridView ? _buildGrid(list) : _buildListView(list),
    );
  }

  Widget _buildListView(List<Event> list) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: list.length,
      itemBuilder: (ctx, i) => _buildListTile(list[i]),
    );
  }

  Widget _buildGrid(List<Event> list) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) => _buildGridTile(list[i]),
    );
  }

  Widget _buildListTile(Event e) {
    final palette = context.palette;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: () => _openDetail(e),
      child: Row(
        children: [
          CategoryBadge(category: e.category),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: palette.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${e.amount.toStringAsFixed(2)} zł · ${e.createdBy.name}',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 13, color: palette.textMuted),
                    const SizedBox(width: 3),
                    Text(e.locationName, style: TextStyle(color: palette.textMuted, fontSize: 12)),
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
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15),
              ),
              Text('zł/os.', style: TextStyle(fontSize: 11, color: palette.textMuted)),
              if (e.isSettled)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: palette.successSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
                  ),
                  child: const Text('OK', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridTile(Event e) {
    final palette = context.palette;
    return AppCard(
      onTap: () => _openDetail(e),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryBadge(category: e.category, size: 40),
              if (e.isSettled)
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
            ],
          ),
          const Spacer(),
          Text(
            e.title,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: palette.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${e.amount.toStringAsFixed(2)} zł',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          Text(
            e.locationName,
            style: TextStyle(color: palette.textMuted, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeEvents = _events.where((e) => !e.isSettled).toList();
    final settledEvents = _events.where((e) => e.isSettled).toList();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _categoryChip(null, 'Wszystkie'),
                        ...categoryEmoji.entries.map((e) => _categoryChip(e.key, '${e.value} ${e.key}')),
                      ],
                    ),
                  ),
                ),
                Material(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _isGridView = !_isGridView),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                          key: ValueKey(_isGridView),
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          PillTabBar(
            controller: _tabController,
            tabs: [
              'Aktywne (${activeEvents.length})',
              'Rozliczone (${settledEvents.length})',
              'Mapa',
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(activeEvents),
                _buildList(settledEvents),
                EventsMapTab(events: _events, loading: _loading, onRefresh: _load),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateEventScreen()),
        ).then((_) => _load()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nowe'),
      ),
    );
  }

  Widget _categoryChip(String? cat, String label) {
    final selected = _selectedCategory == cat;
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : palette.textSecondary,
          ),
        ),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: palette.glassFill,
        side: BorderSide(color: selected ? AppColors.primary : palette.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) {
          setState(() => _selectedCategory = cat);
          _load();
        },
      ),
    );
  }
}
