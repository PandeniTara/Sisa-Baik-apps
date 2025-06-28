// ignore_for_file: unused_import

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sisa_baik/helper/apphelper.dart';
import '../helper/sumbangan_db.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Sumbangan"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: MobileScanner(
        fit: BoxFit.cover,
        onDetect: (capture) async {
          if (_isScanned) return;
          _isScanned = true;

          final qrData = capture.barcodes.first.rawValue;
          if (qrData == null || qrData.isEmpty) {
            _showResult("QR tidak valid atau kosong.");
            return;
          }

          try {
            final Map<String, dynamic> data = jsonDecode(qrData);

            if (!data.containsKey('id')) {
              throw Exception('QR tidak mengandung ID');
            }

            final int id = data['id'];
            final db = AppDatabase();
            final int deleted = await db.deleteDonasi(id);

            if (deleted > 0) {
              _showResult("✅ Sumbangan berhasil dihapus.");
            } else {
              _showResult("⚠️ Sumbangan dengan ID $id tidak ditemukan.");
            }
          } catch (e) {
            _showResult("❌ QR tidak valid atau format salah.");
          }
        },
      ),
    );
  }

  void _showResult(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Hasil Scan"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    ).then((_) {
      setState(() {
        _isScanned = false;
      });
    });
  }
}
