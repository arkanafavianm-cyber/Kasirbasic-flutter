import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_store.dart';
import '../models/product.dart';
import '../models/sale_transaction.dart';

class BackupService {
  static Future<Uint8List> createBackupBytes() async {
    final prefs = await SharedPreferences.getInstance();

    final productsRaw = prefs.getString(productsStorageKey) ?? '[]';
    final transactionsRaw =
        prefs.getString(transactionsStorageKey) ?? '[]';

    final products = jsonDecode(productsRaw) as List<dynamic>;
    final transactions = jsonDecode(transactionsRaw) as List<dynamic>;

    final backup = {
      'app': 'KasirBasic',
      'backupVersion': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'products': products,
      'transactions': transactions,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backup);

    return Uint8List.fromList(utf8.encode(jsonString));
  }

  static Future<Map<String, int>> restoreBackup(
    Uint8List bytes,
  ) async {
    final decoded = jsonDecode(utf8.decode(bytes));

    if (decoded is! Map) {
      throw Exception('Format backup tidak valid.');
    }

    final backup = Map<String, dynamic>.from(decoded);

    if (backup['app'] != 'KasirBasic') {
      throw Exception('File bukan backup KasirBasic.');
    }

    if (backup['backupVersion'] != 1) {
      throw Exception('Versi backup tidak didukung.');
    }

    if (backup['products'] is! List ||
        backup['transactions'] is! List) {
      throw Exception('Data backup tidak lengkap.');
    }

    final productsRaw = backup['products'] as List;
    final transactionsRaw = backup['transactions'] as List;

    // Validasi seluruh data sebelum mengubah penyimpanan.
    final products = productsRaw.map((item) {
      final product = Product.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
      return product.toJson();
    }).toList();

    final transactions = transactionsRaw.map((item) {
      final transaction = SaleTransaction.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
      return transaction.toJson();
    }).toList();

    final prefs = await SharedPreferences.getInstance();

    final productsSaved = await prefs.setString(
      productsStorageKey,
      jsonEncode(products),
    );

    if (!productsSaved) {
      throw Exception('Gagal memulihkan data produk.');
    }

    final transactionsSaved = await prefs.setString(
      transactionsStorageKey,
      jsonEncode(transactions),
    );

    if (!transactionsSaved) {
      throw Exception('Gagal memulihkan transaksi.');
    }

    return {
      'products': products.length,
      'transactions': transactions.length,
    };
  }
}
