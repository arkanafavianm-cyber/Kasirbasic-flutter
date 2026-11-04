
import 'transaction_item.dart';

class SaleTransaction {
  final String id;
  final DateTime date;
  final List<TransactionItem> items;
  final int total;
  final int paid;
  final int change;

  const SaleTransaction({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.paid,
    required this.change,
  });

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items.map((item) => item.toJson()).toList(),
        'total': total,
        'paid': paid,
        'change': change,
      };

  factory SaleTransaction.fromJson(Map<String, dynamic> json) =>
      SaleTransaction(
        id: json['id'].toString(),
        date: DateTime.tryParse(json['date'].toString()) ??
            DateTime.now(),
        items: (json['items'] as List<dynamic>? ?? [])
            .map((item) => TransactionItem.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
        total: (json['total'] as num).toInt(),
        paid: (json['paid'] as num).toInt(),
        change: (json['change'] as num).toInt(),
      );
}
