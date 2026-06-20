import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_styles.dart';
import '../../models/event.dart';
import '../../models/settlement.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

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

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final event = _event!;
    final isPayer = event.createdBy.id == myId;

    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CategoryBadge(category: event.category, size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text('Płaci: ${event.createdBy.name}', style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _infoBox('Łącznie', '${event.amount.toStringAsFixed(2)} zł', AppColors.textPrimary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _infoBox('Na osobę', '${event.splitAmount.toStringAsFixed(2)} zł', AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(event.locationName, style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Rozliczenia (${_settlements.length})'),
          const SizedBox(height: 12),
          ..._settlements.map((s) {
            final isMe = s.participant.id == myId;

            return AppCard(
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      UserAvatar(name: s.participant.name, radius: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.participant.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            StatusChip(status: s.status),
                          ],
                        ),
                      ),
                      AmountLabel(amount: s.amount, suffix: 'zł'),
                    ],
                  ),
                  if (isMe && s.status == 'PENDING') ...[
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => _doAction('claim', s.id),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
                      child: const Text('Oddałem pieniądze'),
                    ),
                  ],
                  if (isPayer && s.status == 'CLAIMED') ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _doAction('confirm', s.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              minimumSize: const Size(0, 44),
                            ),
                            child: const Text('Potwierdź'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _doAction('reject', s.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              minimumSize: const Size(0, 44),
                            ),
                            child: const Text('Odrzuć'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: valueColor)),
        ],
      ),
    );
  }
}
