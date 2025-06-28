import 'package:flutter/material.dart';

class AmbilPage extends StatelessWidget {
  const AmbilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ambil Sumbangan"),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text(
          "Terima kasih! Silakan ambil sumbangan Anda.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
