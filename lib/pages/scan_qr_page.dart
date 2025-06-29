// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sisa_baik/helper/apphelper.dart';
import 'package:sisa_baik/pages/bukti_sumbangan.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with SingleTickerProviderStateMixin {
  bool _isScanned = false;
  late AnimationController _lineAnimation;

  @override
  void initState() {
    super.initState();
    _lineAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _lineAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan QR Sumbangan"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            fit: BoxFit.cover,
            onDetect: (capture) async {
              if (_isScanned) return;
              _isScanned = true;

              final qrData = capture.barcodes.first.rawValue;
              if (qrData == null || qrData.isEmpty) return;

              try {
                final data = jsonDecode(qrData);
                final int id = data['id'];
                final String nama = data['nama'];

                final db = AppDatabase();
                final deleted = await db.deleteDonasi(id);

                if (deleted > 0 && mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BuktiSumbanganPage(namaSumbangan: nama),
                    ),
                  );
                } else {
                  _showErrorDialog(
                    "Sumbangan tidak ditemukan atau sudah diambil.",
                  );
                }
              } catch (_) {
                _showErrorDialog(
                  "QR tidak sesuai format yang digunakan aplikasi ini.",
                );
              }
            },
          ),

          Center(
            child: Stack(
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                Positioned.fill(
                  child: FadeTransition(
                    opacity: Tween(
                      begin: 0.3,
                      end: 1.0,
                    ).animate(_lineAnimation),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 120),
                      height: 2,
                      color: Colors.blueAccent.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan kamera ke QR Code\n dari pihak penyumbang',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Gagal"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isScanned = false);
                },
                child: const Text("Tutup"),
              ),
            ],
          ),
    );
  }
}
