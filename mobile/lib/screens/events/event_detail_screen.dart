import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../models/settlement.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? _event;
  List<Settlement> _settlements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await EventService.getEventDetail(widget.eventId);
      setState(() {
        _event = data['event'];
        _settlements = data['settlements'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _doAction(String action, String settlementId) async {
    Map<String, dynamic> res;
    if (action == 'claim') res = await SettlementService.claim(settlementId);
    else if (action == 'confirm') res = await SettlementService.confirm(settlementId);
    else res = await SettlementService.reject(settlementId);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['success'] == true ? 'Zaktualizowano!' : res['message'] ?? 'Błąd')),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.read<AuthProvider>().user?.id ?? '';

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final event = _event!;
    final isPayer = event.createdBy.id == myId;

    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info o wydarzeniu
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(categoryEmoji[event.category] ?? '📦', style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Płacący: ${event.createdBy.name}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Łącznie: ${event.amount.toStringAsFixed(2)} PLN', style: const TextStyle(fontSize: 16)),
                      Text('Na osobę: ${event.splitAmount.toStringAsFixed(2)} PLN',
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(event.locationName, style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Rozliczenia (${_settlements.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._settlements.map((s) {
            final isMe = s.participant.id == myId;
            final statusE = statusEmoji[s.status] ?? '❓';
            final statusL = statusLabel[s.status] ?? s.status;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(statusE, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s.participant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Text('${s.amount.toStringAsFixed(2)} PLN'),
                      ],
                    ),
                    Text(statusL, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    // Akcje dla uczestnika
                    if (isMe && s.status == 'PENDING')
                      ElevatedButton(
                        onPressed: () => _doAction('claim', s.id),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
                        child: const Text('✅ Oddałem'),
                      ),
                    // Akcje dla płacącego
                    if (isPayer && s.status == 'CLAIMED')
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _doAction('confirm', s.id),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('✅ Potwierdź'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _doAction('reject', s.id),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('❌ Odrzuć'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
