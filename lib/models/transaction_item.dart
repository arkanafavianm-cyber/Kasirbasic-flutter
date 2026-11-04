
class TransactionItem {
  final String productId;
  final String productName;
  final int price;
  final int quantity;

  const TransactionItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  int get subtotal => price * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
      };

  factory TransactionItem.fromJson(
    Map<String, dynamic> json,
  ) =>
      TransactionItem(
        productId: (json['productId'] ?? '').toString(),
        productName: (json['productName'] ?? '').toString(),
        price: (json['price'] as num).toInt(),
        quantity: (json['quantity'] as num).toInt(),
      );
}
