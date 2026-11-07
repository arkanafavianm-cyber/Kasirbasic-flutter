
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

enum ReceiptPaper {
  mm58,
  mm80,
}

class PrinterService {
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

  static Future<bool> printBytes(List<int> bytes) async {
    final connected = await isConnected;

    if (!connected) return false;

    return await PrintBluetoothThermal.writeBytes(bytes);
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

    List<int> bytes = [];

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
      paper == ReceiptPaper.mm58 ? 'Ukuran: 58 mm' : 'Ukuran: 80 mm',
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
