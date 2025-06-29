// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sisa_baik/models/donasi.dart';

class QrCodePage extends StatefulWidget {
  final Donasi sumbangan;

  const QrCodePage({super.key, required this.sumbangan});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  late Timer _timer;
  int _remainingSeconds = 3600;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        setState(() {
          _isExpired = true;
        });
        _timer.cancel();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sumbangan = widget.sumbangan;

    final String qrData = json.encode({
      "id": sumbangan.id,
      "nama": sumbangan.nama,
      "latitude": sumbangan.latitude,
      "longitude": sumbangan.longitude,
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text(
          "Kode QR Sumbangan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Scan QR ini untuk menerima\nsumbangan dengan mudah dan cepat",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // QR Code with embedded logo
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 220,
                  gapless: false,
                  embeddedImage: const AssetImage(
                    'assets/images/icondonasi.png',
                  ),
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: const Size(70, 48),
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.blueAccent),
                    const SizedBox(width: 6),
                    Text(
                      _isExpired
                          ? "QR telah kedaluwarsa"
                          : "Sisa waktu: ${_formatTime(_remainingSeconds)}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _isExpired ? Colors.red : Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  _isExpired
                      ? "QR ini tidak lagi berlaku.\nSilakan kembali untuk membuat QR ulang."
                      : "Tunjukkan QR ini ke Penyumbang untuk memvalidasi dan mengambil sumbangan.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
