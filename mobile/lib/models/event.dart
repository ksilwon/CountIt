import 'user.dart';

class Event {
  final String id;
  final String title;
  final double amount;
  final double splitAmount;
  final String category;
  final DateTime date;
  final User createdBy;
  final List<User> participants;
  final bool isSettled;

  Event({
    required this.id,
    required this.title,
    required this.amount,
    required this.splitAmount,
    required this.category,
    required this.date,
    required this.createdBy,
    required this.participants,
    this.isSettled = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['_id'] ?? '',
        title: json['title'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        splitAmount: (json['splitAmount'] ?? 0).toDouble(),
        category: json['category'] ?? 'inne',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        createdBy: User.fromJson(json['createdBy'] ?? {}),
        participants: (json['participants'] as List<dynamic>? ?? [])
            .map((p) => User.fromJson(p))
            .toList(),
        isSettled: json['isSettled'] ?? false,
      );
}
