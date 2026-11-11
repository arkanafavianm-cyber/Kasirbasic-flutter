
class Product {
  final String id;
  final String name;
  final int price;
  final int stock;
  final String? imageBase64;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageBase64,
  });

  Product copyWith({
    String? name,
    int? price,
    int? stock,
    String? imageBase64,
  }) =>
      Product(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        stock: stock ?? this.stock,
        imageBase64: imageBase64 ?? this.imageBase64,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        'imageBase64': imageBase64,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'].toString(),
        name: json['name'].toString(),
        price: (json['price'] as num).toInt(),
        stock: (json['stock'] as num).toInt(),
        imageBase64: json['imageBase64'] as String?,
      );
}
