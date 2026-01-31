
class Expense {
  final String id;
  final double amount;
  final String currency;
  final String category;
  final String merchant;
  final DateTime date;
  final String source;
  final String type;
  final String? notes;

  final String? userId;

  Expense({
    required this.id,
    required this.amount,
    required this.currency,
    required this.category,
    required this.merchant,
    required this.date,
    required this.source,
    required this.type,
    this.notes,
    this.userId,

  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'INR',
      category: json['category'] ?? 'General',
      merchant: json['merchant'] ?? 'Unknown',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      source: json['source'] ?? 'Manual',
      type: json['type'] ?? 'Purchase',
      notes: json['notes'],
      userId: json['userId'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'category': category,
      'merchant': merchant,
      'date': date.toIso8601String(),
      'source': source,
      'type': type,
      'notes': notes,
      'userId': userId,

    };
  }
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'INR': return '₹';
      default: return currencyCode;
    }
  }

  String get currencySymbol => getCurrencySymbol(currency);
}
