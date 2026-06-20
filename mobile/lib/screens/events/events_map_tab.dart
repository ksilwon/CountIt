import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/constants.dart';
import '../../models/event.dart';
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
      return const Center(child: CircularProgressIndicator());
    }

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Brak wydarzeń na mapie',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
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
          top: 12,
          left: 12,
          right: 12,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.map, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${events.length} wydarzeń · OpenStreetMap',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                    tooltip: 'Odśwież',
                  ),
                ],
              ),
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
      width: 48,
      height: 48,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                categoryEmoji[event.category] ?? '📦',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                event.locationName,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
