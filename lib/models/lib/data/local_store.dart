
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/sale_transaction.dart';

const String productsStorageKey = 'kasirbasic_products';
const String transactionsStorageKey = 'kasirbasic_transactions';

class LocalStore {
  static Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(productsStorageKey);

    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;

      return list
          .map((e) => Product.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveProducts(
    List<Product> products,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      productsStorageKey,
      jsonEncode(
        products.map((p) => p.toJson()).toList(),
      ),
    );
  }

  static Future<List<SaleTransaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(transactionsStorageKey);

    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;

      final result = list
          .map((e) => SaleTransaction.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();

      result.sort((a, b) => b.date.compareTo(a.date));

      return result;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTransactions(
    List<SaleTransaction> transactions,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      transactionsStorageKey,
      jsonEncode(
        transactions.map((t) => t.toJson()).toList(),
      ),
    );
  }
}
