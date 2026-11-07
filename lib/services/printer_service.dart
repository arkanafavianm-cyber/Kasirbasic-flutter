
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sale_transaction.dart';

enum ReceiptPaper {
  mm58,
  mm80,
}

class PrinterService {
  static const String _paperStorageKey = 'kasirbasic_receipt_paper';

  static Future<bool> get isBluetoothEnabled =>
      PrintBluetoothThermal.bluetoothEnabled;

  static Future<bool> get isConnected =>
      PrintBluetoothThermal.connectionStatus;

  static Future<List<BluetoothInfo>> getPairedDevices() async {
    return await PrintBluetoothThermal.pairedBluetooths;
  }

  static Future<bool> connect(String macAddress) async {
    return await PrintBluetoothThermal.connect(
      macPrinterAddress: macAddress,
    );
  }

  static Future<bool> disconnect() async {
    return await PrintBluetoothThermal.disconnect;
  }

  static Future<ReceiptPaper> loadPaper() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_paperStorageKey) == '58'
        ? ReceiptPaper.mm58
        : ReceiptPaper.mm80;
  }

  static Future<void> savePaper(ReceiptPaper paper) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _paperStorageKey,
      paper == ReceiptPaper.mm58 ? '58' : '80',
    );
  }

  static Future<bool> printBytes(List<int> bytes) async {
    final connected = await isConnected;

    if (!connected) return false;

    return await PrintBluetoothThermal.writeBytes(bytes);
  }

  static String _rupiah(int value) {
    final digits = value.toString();
    final result = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      result.write(digits[i]);

      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        result.write('.');
      }
    }

    return 'Rp$result';
  }

  static String _dateTime(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  static Future<List<int>> createTransactionReceipt({
    required SaleTransaction transaction,
    required ReceiptPaper paper,
  }) async {
    final profile = await CapabilityProfile.load();

    final generator = Generator(
      paper == ReceiptPaper.mm58
          ? PaperSize.mm58
          : PaperSize.mm80,
      profile,
    );

    final bytes = <int>[];

    bytes += generator.reset();

    bytes += generator.text(
      'KASIR BASIC',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.text(
      'STRUK PEMBELIAN',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr();
    bytes += generator.text('No: ${transaction.id}');
    bytes += generator.text('Tanggal: ${_dateTime(transaction.date)}');
    bytes += generator.hr();

    for (final item in transaction.items) {
      bytes += generator.text(item.productName);

      bytes += generator.row([
        PosColumn(
          text: '${item.quantity} x ${_rupiah(item.price)}',
          width: 7,
        ),
        PosColumn(
          text: _rupiah(item.subtotal),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
        text: 'TOTAL',
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: _rupiah(transaction.total),
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
        ),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Dibayar', width: 6),
      PosColumn(
        text: _rupiah(transaction.paid),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Kembalian', width: 6),
      PosColumn(
        text: _rupiah(transaction.change),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    bytes += generator.text(
      'Terima kasih',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  static Future<bool> printTransaction(
    SaleTransaction transaction,
  ) async {
    final paper = await loadPaper();

    final bytes = await createTransactionReceipt(
      transaction: transaction,
      paper: paper,
    );

    return printBytes(bytes);
  }

  static Future<List<int>> createTestReceipt({
    required ReceiptPaper paper,
  }) async {
    final profile = await CapabilityProfile.load();

    final generator = Generator(
      paper == ReceiptPaper.mm58
          ? PaperSize.mm58
          : PaperSize.mm80,
      profile,
    );

    final bytes = <int>[];

    bytes += generator.reset();

    bytes += generator.text(
      'KASIR BASIC',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.text(
      'Tes Cetak Struk',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr();
    bytes += generator.text('Printer Bluetooth: OK');

    bytes += generator.text(
      paper == ReceiptPaper.mm58
          ? 'Ukuran: 58 mm'
          : 'Ukuran: 80 mm',
    );

    bytes += generator.hr();

    bytes += generator.text(
      'Terima kasih',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }
}
