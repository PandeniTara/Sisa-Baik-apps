import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sisa_baik/models/donasi.dart';

class QrCodePage extends StatelessWidget {
  final Donasi sumbangan;

  const QrCodePage({super.key, required this.sumbangan});

  @override
  Widget build(BuildContext context) {
    // ✅ Gunakan json.encode agar aman dari karakter spesial
    final String qrData = json.encode({
      "id": sumbangan.id,
      "nama": sumbangan.nama,
      "latitude": sumbangan.latitude,
      "longitude": sumbangan.longitude,
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Sumbangan"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Tunjukkan QR ini ke petugas",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            // ✅ QR Code aman
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250,
              gapless: false,
            ),

            const SizedBox(height: 24),
            const Text(
              "Petugas akan memindai kode ini\nuntuk memvalidasi dan menghapus sumbangan.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
