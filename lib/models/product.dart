
class Product {
  final String id;
  final String name;
  final int price;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  Product copyWith({
    String? name,
    int? price,
    int? stock,
  }) =>
      Product(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        stock: stock ?? this.stock,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'].toString(),
        name: json['name'].toString(),
        price: (json['price'] as num).toInt(),
        stock: (json['stock'] as num).toInt(),
      );
}
