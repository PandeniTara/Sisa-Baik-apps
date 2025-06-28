// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sisa_baik/helper/apphelper.dart';
import 'package:sisa_baik/models/donasi.dart';
import 'sumbangan.detail.dart';

class SumbanganContent extends StatefulWidget {
  const SumbanganContent({super.key});

  @override
  State<SumbanganContent> createState() => _SumbanganContentState();
}

class _SumbanganContentState extends State<SumbanganContent> {
  String _selectedKategori = "All";
  List<Donasi> _sumbanganList = [];

  final List<String> _kategoriList = [
    "All",
    "Makanan",
    "Sayur",
    "Buah",
    "Bahan Pokok",
  ];

  @override
  void initState() {
    super.initState();
    _loadSumbangan();
  }

  Future<void> _loadSumbangan() async {
    final data = await AppDatabase().getAllDonasi();
    setState(() {
      _sumbanganList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        centerTitle: true,
        title: const Text(
          "Sumbangan",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔄 Filter Kategori
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _kategoriList.length,
                itemBuilder: (context, index) {
                  final kategori = _kategoriList[index];
                  final isSelected = kategori == _selectedKategori;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedKategori = kategori;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueAccent : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.blueAccent),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Colors.blueAccent.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Text(
                          kategori,
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 📦 List Sumbangan
            Expanded(
              child:
                  _sumbanganList.isEmpty
                      ? const Center(
                        child: Text(
                          'Belum ada data sumbangan.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                      : ListView(
                        children:
                            _sumbanganList
                                .where(
                                  (item) =>
                                      _selectedKategori == "All" ||
                                      item.jenisMakanan.name.toLowerCase() ==
                                          _selectedKategori.toLowerCase(),
                                )
                                .map((item) => _buildDonationCard(item))
                                .toList(),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(Donasi item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SumbanganDetailPage(sumbangan: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                File(item.imagePath!),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nama,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${item.jumlah} kg/pcs",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  if (item.latitude != null && item.longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.latitude!.toStringAsFixed(5)}, ${item.longitude!.toStringAsFixed(5)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
