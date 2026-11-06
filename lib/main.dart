import 'package:flutter/material.dart';

import 'data/local_store.dart';
import 'models/product.dart';
import 'models/sale_transaction.dart';
import 'models/transaction_item.dart';
import 'pages/backup_page.dart';

void main() {
  runApp(const KasirBasicApp());
}

class KasirBasicApp extends StatelessWidget {
  const KasirBasicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KasirBasic',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B52)),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(centerTitle: false),
        cardTheme: CardThemeData(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

String rupiah(int value) {
  final digits = value.toString();
  final result = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    result.write(digits[i]);
    final remaining = digits.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) result.write('.');
  }
  return 'Rp$result';
}

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int todaySales = 0;
  int todayTransactions = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final transactions = await LocalStore.loadTransactions();
    final now = DateTime.now();
    final today = transactions.where((t) => sameDay(t.date, now)).toList();
    if (!mounted) return;
    setState(() {
      todaySales = today.fold(0, (sum, t) => sum + t.total);
      todayTransactions = today.length;
      loading = false;
    });
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => page));
    _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KasirBasic',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSummary,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
  Center(
    child: Image.asset(
      'assets/images/logo.png',
      width: 110,
      height: 110,
      fit: BoxFit.contain,
    ),
  ),
  const SizedBox(height: 12),
  const Text(
    'Selamat Datang!',
    style: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 6),
  const Text('Kelola penjualan tokomu dengan mudah.'),
  const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Penjualan Hari Ini'),
                    const SizedBox(height: 8),
                    Text(loading ? 'Memuat...' : rupiah(todaySales),
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('$todayTransactions transaksi'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Menu Utama',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  childAspectRatio: 1.12,
  children: [
    _menu(Icons.point_of_sale, 'Mulai Kasir',
        () => _open(const CashierPage())),
    _menu(Icons.inventory_2_outlined, 'Produk',
        () => _open(const ProductsPage())),
    _menu(Icons.receipt_long, 'Transaksi',
        () => _open(const TransactionsPage())),
    _menu(Icons.bar_chart, 'Laporan',
        () => _open(const ReportsPage())),
    _menu(Icons.backup_outlined, 'Backup & Restore',
        () => _open(const BackupPage())),
  ],
),
            const SizedBox(height: 12),
            const Text(
              'Catatan: data tersimpan di perangkat ini. Buat cadangan secara berkala jika aplikasi digunakan untuk usaha.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menu(IconData icon, String title, VoidCallback onTap) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final loaded = await LocalStore.loadProducts();
    if (!mounted) return;
    setState(() {
      products = loaded;
      loading = false;
    });
  }

  Future<void> _save() async => LocalStore.saveProducts(products);

  Future<void> _addProduct() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    final result = await showDialog<Product>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'Nama produk', border: OutlineInputBorder()),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Harga jual (Rp)',
                      border: OutlineInputBorder()),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return n == null || n <= 0
                        ? 'Masukkan harga yang valid'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Stok awal', border: OutlineInputBorder()),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return n == null || n < 0
                        ? 'Stok harus 0 atau lebih'
                        : null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                dialogContext,
                Product(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  price: int.parse(priceController.text),
                  stock: int.parse(stockController.text),
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    nameController.dispose();
    priceController.dispose();
    stockController.dispose();

    if (result != null) {
      setState(() => products.add(result));
      await _save();
    }
  }

  Future<void> _editProduct(Product product) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: product.name);
    final priceController =
        TextEditingController(text: product.price.toString());
    final stockController =
        TextEditingController(text: product.stock.toString());

    final result = await showDialog<Product>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Produk'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama produk',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga jual (Rp)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return n == null || n <= 0
                        ? 'Masukkan harga yang valid'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return n == null || n < 0
                        ? 'Stok harus 0 atau lebih'
                        : null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                dialogContext,
                product.copyWith(
                  name: nameController.text.trim(),
                  price: int.parse(priceController.text),
                  stock: int.parse(stockController.text),
                ),
              );
            },
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );

    nameController.dispose();
    priceController.dispose();
    stockController.dispose();

    if (result != null) {
      setState(() {
        final index = products.indexWhere((p) => p.id == product.id);
        if (index != -1) products[index] = result;
      });
      await _save();
    }
  }
Future<void> editProduct(Product product) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: product.name);
  final priceController =
      TextEditingController(text: product.price.toString());
  final stockController =
      TextEditingController(text: product.stock.toString());

  final result = await showDialog<Product>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Edit Produk'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama produk',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Nama wajib diisi'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga jual (Rp)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  return n == null || n <= 0
                      ? 'Masukkan harga yang valid'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  return n == null || n < 0
                      ? 'Stok harus 0 atau lebih'
                      : null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            Navigator.pop(
              dialogContext,
              product.copyWith(
                name: nameController.text.trim(),
                price: int.parse(priceController.text),
                stock: int.parse(stockController.text),
              ),
            );
          },
          child: const Text('Simpan Perubahan'),
        ),
      ],
    ),
  );

  nameController.dispose();
  priceController.dispose();
  stockController.dispose();

  if (result != null) {
    setState(() {
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) products[index] = result;
    });
    await _save();
  }
}
  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text('Produk "${product.name}" akan dihapus dari daftar.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => products.removeWhere((p) => p.id == product.id));
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Produk')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Belum ada produk.\nTekan Tambah Produk untuk mulai.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                            child: Icon(Icons.inventory_2_outlined)),
                        title: Text(product.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle:
                            Text('${rupiah(product.price)}\nStok: ${product.stock}'),
                        isThreeLine: true,
                        trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.edit_outlined),
      tooltip: 'Edit produk',
      onPressed: () => editProduct(product),
    ),
    IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: 'Hapus produk',
      onPressed: () => _deleteProduct(product),
    ),
  ],
),
                      ),
                    );
                  },
                ),
    );
  }
}

class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  List<Product> products = [];
  final Map<String, int> cart = {};
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final loaded = await LocalStore.loadProducts();
    if (!mounted) return;
    setState(() {
      products = loaded;
      loading = false;
    });
  }

  Product? _productById(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  int get total => cart.entries.fold(0, (sum, entry) {
        final product = _productById(entry.key);
        return sum + (product == null ? 0 : product.price * entry.value);
      });

  int get itemCount => cart.values.fold(0, (sum, qty) => sum + qty);

  void _changeQty(Product product, int delta) {
    final current = cart[product.id] ?? 0;
    final next = current + delta;
    if (next < 0) return;
    if (next > product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok ${product.name} hanya ${product.stock}.')),
      );
      return;
    }
    setState(() {
      if (next == 0) {
        cart.remove(product.id);
      } else {
        cart[product.id] = next;
      }
    });
  }

  Future<void> _checkout() async {
    if (cart.isEmpty || saving) return;

    // Muat ulang data agar stok yang dipakai adalah stok tersimpan terbaru.
    final latestProducts = await LocalStore.loadProducts();
    final latestById = {for (final p in latestProducts) p.id: p};
    for (final entry in cart.entries) {
      final product = latestById[entry.key];
      if (product == null || product.stock < entry.value) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Stok produk berubah. Periksa keranjang lalu coba lagi.')),
        );
        await _loadProducts();
        return;
      }
    }

    final paidController = TextEditingController(text: total.toString());
    final formKey = GlobalKey<FormState>();
    final paid = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pembayaran'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total: ${rupiah(total)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextFormField(
                controller: paidController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Uang diterima (Rp)',
                    border: OutlineInputBorder()),
                validator: (value) {
                  final amount = int.tryParse(value ?? '');
                  if (amount == null || amount < total) {
                    return 'Uang harus minimal ${rupiah(total)}';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogContext, int.parse(paidController.text));
            },
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
    paidController.dispose();
    if (paid == null || !mounted) return;

    setState(() => saving = true);
    try {
      // Recheck stock immediately before saving the sale.
      final currentProducts = await LocalStore.loadProducts();
      final currentById = {for (final p in currentProducts) p.id: p};
      for (final entry in cart.entries) {
        final p = currentById[entry.key];
        if (p == null || p.stock < entry.value) {
          throw Exception('Stok berubah. Silakan ulangi transaksi.');
        }
      }

      final items = <TransactionItem>[];
      final updatedProducts = currentProducts.map((p) {
        final quantity = cart[p.id] ?? 0;
        if (quantity > 0) {
          items.add(TransactionItem(
            productId: p.id,
            productName: p.name,
            price: p.price,
            quantity: quantity,
          ));
          return p.copyWith(stock: p.stock - quantity);
        }
        return p;
      }).toList();

      final saleTotal =
          items.fold(0, (sum, item) => sum + item.subtotal);
      final transaction = SaleTransaction(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: DateTime.now(),
        items: items,
        total: saleTotal,
        paid: paid,
        change: paid - saleTotal,
      );

      await LocalStore.saveProducts(updatedProducts);
      final transactions = await LocalStore.loadTransactions();
      transactions.insert(0, transaction);
      await LocalStore.saveTransactions(transactions);

      if (!mounted) return;
      setState(() {
        products = updatedProducts;
        cart.clear();
        saving = false;
      });
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Transaksi berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total: ${rupiah(saleTotal)}'),
              Text('Dibayar: ${rupiah(paid)}'),
              Text('Kembalian: ${rupiah(paid - saleTotal)}'),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      await _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = products.where((p) => p.stock > 0).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Mulai Kasir')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(
                  child: Text('Belum ada produk. Tambahkan produk terlebih dahulu.'),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Pilih produk',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                          if (available.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('Semua stok produk sedang habis.'),
                            ),
                          ...products.map((product) {
                            final qty = cart[product.id] ?? 0;
                            return Card(
                              child: ListTile(
                                title: Text(product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${rupiah(product.price)} • Stok: ${product.stock}'),
                                trailing: SizedBox(
                                  width: 132,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: qty > 0
                                            ? () => _changeQty(product, -1)
                                            : null,
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                      ),
                                      Text('$qty',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      IconButton(
                                        onPressed: product.stock > qty
                                            ? () => _changeQty(product, 1)
                                            : null,
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 8)
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$itemCount barang'),
                                Text(rupiah(total),
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              onPressed:
                                  cart.isNotEmpty && !saving ? _checkout : null,
                              icon: saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.payment),
                              label: Text(
                                  saving ? 'Menyimpan...' : 'Bayar / Selesaikan'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<SaleTransaction> transactions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await LocalStore.loadTransactions();
    if (!mounted) return;
    setState(() {
      transactions = loaded;
      loading = false;
    });
  }

  String _dateTime(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
  }

  void _showDetail(SaleTransaction transaction) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Detail Transaksi'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_dateTime(transaction.date)),
                const SizedBox(height: 12),
                ...transaction.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Text(
                                  '${item.productName}\n${item.quantity} × ${rupiah(item.price)}')),
                          Text(rupiah(item.subtotal)),
                        ],
                      ),
                    )),
                const Divider(),
                _detailRow('Total', rupiah(transaction.total)),
                _detailRow('Dibayar', rupiah(transaction.paid)),
                _detailRow('Kembalian', rupiah(transaction.change)),
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text('Belum ada transaksi.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                              child: Icon(Icons.receipt_long)),
                          title: Text(rupiah(transaction.total),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${_dateTime(transaction.date)}\n${transaction.totalItems} barang • ${transaction.items.length} jenis produk'),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showDetail(transaction),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<SaleTransaction> transactions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await LocalStore.loadTransactions();
    if (!mounted) return;
    setState(() {
      transactions = loaded;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = transactions.where((t) => sameDay(t.date, now)).toList();
    final month = transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();
    final todaySales = today.fold(0, (sum, t) => sum + t.total);
    final monthSales = month.fold(0, (sum, t) => sum + t.total);
    final todayItems = today.fold(0, (sum, t) => sum + t.totalItems);
    final monthItems = month.fold(0, (sum, t) => sum + t.totalItems);

    final Map<String, int> productSales = {};
    for (final transaction in month) {
      for (final item in transaction.items) {
        productSales[item.productName] =
            (productSales[item.productName] ?? 0) + item.quantity;
      }
    }
    final topProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        actions: [
          IconButton(
              onPressed: _load,
              tooltip: 'Muat ulang',
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Ringkasan Hari Ini',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _reportCard('Omzet hari ini', rupiah(todaySales),
                      Icons.payments_outlined),
                  _reportCard(
                      'Jumlah transaksi hari ini',
                      '${today.length} transaksi',
                      Icons.receipt_long_outlined),
                  _reportCard('Barang terjual hari ini', '$todayItems barang',
                      Icons.shopping_bag_outlined),
                  const SizedBox(height: 20),
                  const Text('Ringkasan Bulan Ini',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _reportCard('Omzet bulan ini', rupiah(monthSales),
                      Icons.account_balance_wallet_outlined),
                  _reportCard('Jumlah transaksi bulan ini',
                      '${month.length} transaksi', Icons.calendar_month),
                  _reportCard('Barang terjual bulan ini', '$monthItems barang',
                      Icons.inventory_2_outlined),
                  const SizedBox(height: 20),
                  const Text('Produk Terlaris Bulan Ini',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (topProducts.isEmpty)
                    const Card(
                        child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Belum ada penjualan bulan ini.'),
                    ))
                  else
                    ...topProducts.take(5).map((entry) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.trending_up),
                            title: Text(entry.key),
                            trailing: Text('${entry.value} terjual',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        )),
                  const SizedBox(height: 12),
                  const Text(
                    'Omzet dihitung dari total transaksi yang tersimpan di perangkat ini. Ini laporan penjualan, bukan laba bersih.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _reportCard(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
