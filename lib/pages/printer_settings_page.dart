import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../services/printer_service.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() =>
      _PrinterSettingsPageState();
}

class _PrinterSettingsPageState
    extends State<PrinterSettingsPage> {
  List<BluetoothInfo> devices = [];
  bool bluetoothEnabled = false;
  bool connected = false;
  bool loading = false;

  ReceiptPaper selectedPaper = ReceiptPaper.mm58;

  String message = 'Belum ada printer terhubung';

  @override
  void initState() {
    super.initState();
    checkStatus();
  }

  Future<void> checkStatus() async {
    final enabled = await PrinterService.isBluetoothEnabled;
    final status = await PrinterService.isConnected;

    if (!mounted) return;

    setState(() {
      bluetoothEnabled = enabled;
      connected = status;
    });
  }

  Future<void> scanDevices() async {
    setState(() {
      loading = true;
      message = 'Memuat perangkat Bluetooth...';
    });

    try {
      final enabled = await PrinterService.isBluetoothEnabled;

      if (!enabled) {
        setState(() {
          bluetoothEnabled = false;
          devices = [];
          message = 'Aktifkan Bluetooth terlebih dahulu.';
        });
        return;
      }

      final result = await PrinterService.getPairedDevices();

      if (!mounted) return;

      setState(() {
        bluetoothEnabled = true;
        devices = result;
        message = result.isEmpty
            ? 'Belum ada perangkat yang dipasangkan.'
            : 'Pilih printer untuk menghubungkan.';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          message = 'Gagal memuat perangkat: $e';
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> connectPrinter(String mac) async {
    setState(() => loading = true);

    try {
      final result = await PrinterService.connect(mac);

      if (!mounted) return;

      setState(() {
        connected = result;
        message = result
            ? 'Printer berhasil terhubung.'
            : 'Gagal menghubungkan printer.';
      });
    } catch (e) {
      if (mounted) {
        setState(() => message = 'Koneksi gagal: $e');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> disconnectPrinter() async {
    await PrinterService.disconnect();

    if (!mounted) return;

    setState(() {
      connected = false;
      message = 'Printer terputus.';
    });
  }

  Future<void> testPrint() async {
    setState(() => loading = true);

    try {
      final bytes = await PrinterService.createTestReceipt(
        paper: selectedPaper,
      );

      final result = await PrinterService.printBytes(bytes);

      if (!mounted) return;

      setState(() {
        message = result
            ? 'Perintah cetak berhasil dikirim.'
            : 'Gagal mengirim perintah cetak.';
      });
    } catch (e) {
      if (mounted) {
        setState(() => message = 'Cetak gagal: $e');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.print,
            size: 70,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            'Printer Thermal Bluetooth',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: Icon(
                Icons.bluetooth,
                color: bluetoothEnabled ? Colors.blue : Colors.grey,
              ),
              title: const Text('Status Bluetooth'),
              subtitle: Text(
                bluetoothEnabled ? 'Aktif' : 'Tidak aktif',
              ),
              trailing: Icon(
                connected ? Icons.check_circle : Icons.circle_outlined,
                color: connected ? Colors.green : Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Ukuran Kertas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          RadioListTile<ReceiptPaper>(
            title: const Text('58 mm'),
            value: ReceiptPaper.mm58,
            groupValue: selectedPaper,
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedPaper = value);
              }
            },
          ),

          RadioListTile<ReceiptPaper>(
            title: const Text('80 mm'),
            value: ReceiptPaper.mm80,
            groupValue: selectedPaper,
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedPaper = value);
              }
            },
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: loading ? null : scanDevices,
            icon: const Icon(Icons.search),
            label: const Text('Cari Printer Terpasang'),
          ),

          const SizedBox(height: 12),

          Text(
            message,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          ...devices.map((device) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.print),
                title: Text(device.name),
                subtitle: Text(device.macAdress),
                trailing: const Icon(Icons.bluetooth_connected),
                onTap: loading
                    ? null
                    : () => connectPrinter(device.macAdress),
              ),
            );
          }),

          const SizedBox(height: 16),

          if (connected) ...[
            OutlinedButton.icon(
              onPressed: loading ? null : disconnectPrinter,
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('Putuskan Koneksi'),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: loading ? null : testPrint,
              icon: const Icon(Icons.print),
              label: const Text('Cetak Tes'),
            ),
          ],

          if (loading) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],

          const SizedBox(height: 20),

          const Text(
            'Catatan: Printer harus dipasangkan melalui '
            'pengaturan Bluetooth Android terlebih dahulu.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
