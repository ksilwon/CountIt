import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_styles.dart';
import '../../config/constants.dart';
import '../../models/event.dart';
import '../../widgets/common_widgets.dart';
import 'event_detail_screen.dart';

class EventsMapTab extends StatelessWidget {
  final List<Event> events;
  final bool loading;
  final VoidCallback onRefresh;

  const EventsMapTab({
    super.key,
    required this.events,
    required this.loading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (events.isEmpty) {
      return const EmptyState(
        icon: Icons.map_outlined,
        title: 'Brak wydarzeń na mapie',
        subtitle: 'Wydarzenia z lokalizacją pojawią się tutaj',
      );
    }

    final center = _mapCenter(events);

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: events.length == 1 ? 13 : 6,
            minZoom: 5,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.countit.app',
            ),
            MarkerLayer(
              markers: events.map((e) => _buildMarker(context, e)).toList(),
            ),
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.soft,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.map_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${events.length} wydarzeń',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const Text('OpenStreetMap', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  onPressed: onRefresh,
                  tooltip: 'Odśwież',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LatLng _mapCenter(List<Event> events) {
    if (events.length == 1) {
      return LatLng(events.first.latitude, events.first.longitude);
    }
    final avgLat = events.map((e) => e.latitude).reduce((a, b) => a + b) / events.length;
    final avgLng = events.map((e) => e.longitude).reduce((a, b) => a + b) / events.length;
    return LatLng(avgLat, avgLng);
  }

  Marker _buildMarker(BuildContext context, Event event) {
    return Marker(
      point: LatLng(event.latitude, event.longitude),
      width: 56,
      height: 56,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                shape: BoxShape.circle,
                boxShadow: AppShadows.card,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(categoryEmoji[event.category] ?? '📦', style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: AppShadows.soft,
              ),
              child: Text(
                event.locationName,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
