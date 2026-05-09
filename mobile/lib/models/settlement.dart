import 'user.dart';
import 'event.dart';

class Settlement {
  final String id;
  final String eventId;
  final String? eventTitle;
  final User participant;
  final User payer;
  final double amount;
  final String status;
  final DateTime? claimedAt;
  final DateTime? confirmedAt;

  Settlement({
    required this.id,
    required this.eventId,
    this.eventTitle,
    required this.participant,
    required this.payer,
    required this.amount,
    required this.status,
    this.claimedAt,
    this.confirmedAt,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    final eventData = json['event'];
    return Settlement(
      id: json['_id'] ?? '',
      eventId: eventData is Map ? (eventData['_id'] ?? '') : (eventData ?? ''),
      eventTitle: eventData is Map ? eventData['title'] : null,
      participant: User.fromJson(json['participant'] ?? {}),
      payer: User.fromJson(json['payer'] ?? {}),
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      claimedAt: json['claimedAt'] != null ? DateTime.tryParse(json['claimedAt']) : null,
      confirmedAt: json['confirmedAt'] != null ? DateTime.tryParse(json['confirmedAt']) : null,
    );
  }
}
