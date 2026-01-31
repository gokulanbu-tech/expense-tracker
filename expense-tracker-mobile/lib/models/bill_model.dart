
class Bill {
  final String id;
  final String merchant;
  final String category;
  final String? note;
  final String type;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? lastPaidDate;
  final String frequency;
  final String? userId;

  Bill({
    required this.id,
    required this.merchant,
    required this.category,
    this.note,
    required this.type,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    this.lastPaidDate,
    required this.frequency,
    this.userId,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] ?? '',
      merchant: json['merchant'] ?? 'Unknown',
      category: json['category'] ?? 'General',
      note: json['note'],
      type: json['type'] ?? 'Debit',
      amount: (json['amount'] ?? 0.0).toDouble(),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : DateTime.now(),
      isPaid: json['isPaid'] ?? false,
      lastPaidDate: json['lastPaidDate'] != null ? DateTime.parse(json['lastPaidDate']) : null,
      frequency: json['frequency'] ?? 'MONTHLY',
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant': merchant,
      'category': category,
      'note': note,
      'type': type,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'isPaid': isPaid,
      'lastPaidDate': lastPaidDate?.toIso8601String(),
      'frequency': frequency,
      'userId': userId,
    };
  }
}
