import 'package:flutter/material.dart';

class FavoriteContent extends StatelessWidget {
  const FavoriteContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('Favorit Saya'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Daftar tempat wisata yang Anda sukai akan tampil di sini.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
