import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/backup_service.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool isLoading = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> createBackup() async {
    setState(() => isLoading = true);

    try {
      final bytes = await BackupService.createBackupBytes();

      final now = DateTime.now();
      final fileName =
          'kasirbasic_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';

      final path = await FilePicker.saveFile(
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (!mounted) return;

      if (path != null) {
        showMessage('Backup berhasil disimpan.');
      }
    } catch (e) {
      if (mounted) showMessage('Backup gagal: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> restoreBackup() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();

      if (!mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pulihkan Backup?'),
          content: const Text(
            'Data produk dan transaksi saat ini akan diganti '
            'dengan data dari file backup. Pastikan data saat ini '
            'sudah dicadangkan terlebih dahulu.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Pulihkan'),
            ),
          ],
        ),
      );

      if (confirm != true || !mounted) return;

      setState(() => isLoading = true);

      final counts = await BackupService.restoreBackup(bytes);

      if (!mounted) return;

      showMessage(
        'Berhasil! ${counts['products']} produk dan '
        '${counts['transactions']} transaksi dipulihkan.',
      );
    } catch (e) {
      if (mounted) showMessage('Restore gagal: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.cloud_sync_outlined,
              size: 72,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Lindungi Data KasirBasic',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simpan data produk dan transaksi ke file backup '
              'agar bisa dipulihkan kembali.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: isLoading ? null : createBackup,
              icon: const Icon(Icons.save_alt),
              label: const Text('Buat Backup'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: isLoading ? null : restoreBackup,
              icon: const Icon(Icons.restore),
              label: const Text('Restore Backup'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            if (isLoading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 24),
            const Text(
              'Catatan: Restore akan mengganti data produk '
              'dan transaksi yang tersimpan saat ini.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
