
class Product {
  final String id;
  final String name;
  final int price;
  final double stock;
  final String? imageBase64;
  final String category;
  final String unit;
  final double averageCost;
  final double minStock;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageBase64,
    this.category = 'Umum',
    this.unit = 'pcs',
    this.averageCost = 0,
    this.minStock = 0,
  });

  Product copyWith({
    String? name,
    int? price,
    double? stock,
    String? imageBase64,
    bool clearImage = false,
    String? category,
    String? unit,
    double? averageCost,
    double? minStock,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageBase64: clearImage
          ? null
          : imageBase64 ?? this.imageBase64,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      averageCost: averageCost ?? this.averageCost,
      minStock: minStock ?? this.minStock,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'stock': stock,
    'imageBase64': imageBase64,
    'category': category,
    'unit': unit,
    'averageCost': averageCost,
    'minStock': minStock,
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'].toString(),
      price: (json['price'] as num).toInt(),
      stock: (json['stock'] as num).toDouble(),
      imageBase64: json['imageBase64'] as String?,
      category: (json['category'] ?? 'Umum').toString(),
      unit: (json['unit'] ?? 'pcs').toString(),
      averageCost:
          (json['averageCost'] as num?)?.toDouble() ?? 0,
      minStock:
          (json['minStock'] as num?)?.toDouble() ?? 0,
    );
  }
}
