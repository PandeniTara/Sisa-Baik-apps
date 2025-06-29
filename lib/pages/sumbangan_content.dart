// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color(0xFFF2F6FC),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Sumbangan",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFilterChips(),
            const SizedBox(height: 20),
            _sumbanganList.isEmpty
                ? Expanded(
                  child: Center(
                    child: Text(
                      'Belum ada data sumbangan.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                )
                : Expanded(
                  child: ListView(
                    children:
                        _sumbanganList
                            .where(
                              (item) =>
                                  _selectedKategori == "All" ||
                                  item.jenisMakanan.name.toLowerCase() ==
                                      _selectedKategori.toLowerCase(),
                            )
                            .map(_buildDonationCard)
                            .toList(),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _kategoriList.length,
        itemBuilder: (context, index) {
          final kategori = _kategoriList[index];
          final isSelected = kategori == _selectedKategori;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                setState(() {
                  _selectedKategori = kategori;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.1),
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
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nama,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (item.latitude != null && item.longitude != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.latitude!.toStringAsFixed(5)}, ${item.longitude!.toStringAsFixed(5)}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
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
