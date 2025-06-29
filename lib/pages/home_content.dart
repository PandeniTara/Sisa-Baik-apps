// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sisa_baik/helper/apphelper.dart';
import 'package:sisa_baik/models/user_model.dart';
import 'package:sisa_baik/models/donasi.dart';
import 'package:sisa_baik/pages/form_content.dart';
import 'package:sisa_baik/preferences/prefs.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _allItems = [
    {"title": "Makanan"},
    {"title": "Sayur"},
    {"title": "Buah"},
    {"title": "Bahan Pokok"},
  ];
  String _searchQuery = "";
  User? _user;
  List<Donasi> _rekomendasi = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadRekomendasi();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Selamat pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat sore';
    } else {
      return 'Selamat malam';
    }
  }

  Color _getPoinLevelColor(int poin) {
    if (poin <= 100) {
      return const Color(0xFFCD7F32); // Bronze
    } else if (poin <= 200) {
      return const Color(0xFFC0C0C0); // Silver
    } else if (poin <= 300) {
      return const Color(0xFFFFD700); // Gold
    } else {
      return Colors.blueAccent; // Diamond
    }
  }

  Future<void> _loadUser() async {
    final id = await Prefs.getUserId();
    if (id != null) {
      final user = await AppDatabase().getUserById(id);
      setState(() {
        _user = user;
      });
    }
  }

  Future<void> _loadRekomendasi() async {
    final data = await AppDatabase().getAllDonasi();
    setState(() {
      _rekomendasi = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> listToDisplay =
        _rekomendasi
            .where(
              (d) => d.nama.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .map((d) {
              return {
                "title": d.nama,
                "image": d.imagePath != null ? File(d.imagePath!) : null,
                "jumlah": d.jumlah,
                "jenis": d.jenisMakanan.name,
              };
            })
            .toList();

    final poinColor = _getPoinLevelColor(_user?.totalPoin ?? 0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 251, 251, 251),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.blueAccent, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            (_user?.foto != null &&
                                    File(_user!.foto!).existsSync())
                                ? FileImage(File(_user!.foto!))
                                : const AssetImage('assets/default_avatar.png')
                                    as ImageProvider,
                        child:
                            (_user?.foto == null)
                                ? const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey,
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user?.nama ?? 'Pengguna',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  color: poinColor.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: poinColor,
                          ),
                          child: const Icon(Icons.star, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Poin Kamu",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${_user?.totalPoin ?? 0} poin",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Cari sumbangan disini...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.blue.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color.fromARGB(255, 0, 0, 210).withOpacity(1),
                        const Color.fromARGB(0, 103, 177, 255),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Ribuan anak tidak mendapatkan makanan bergizi karena keterbatasan ekonomi!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FormSumbangan(),
                            ),
                          );
                          if (result != null && result is Map) {
                            _loadRekomendasi(); // update list
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Sumbangkan sekarang',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Pilihan Donasi Hari Ini",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        _allItems
                            .map((item) => _buildColorCard(item['title']))
                            .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _searchQuery.isEmpty
                      ? "Rekomendasi Untuk Kamu"
                      : "Hasil Pencarian",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children:
                      listToDisplay
                          .map(
                            (item) => _buildRecommendationCard(
                              title: item['title'],
                              image: item['image'],
                              jumlah: item['jumlah'] ?? "-",
                              jenis: item['jenis'] ?? "-",
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorCard(String title) {
    final colorMap = {
      "Makanan": Colors.orange,
      "Sayur": Colors.green,
      "Buah": Colors.redAccent,
      "Bahan Pokok": Colors.blue,
    };

    final iconMap = {
      "Makanan": Icons.fastfood,
      "Sayur": Icons.eco,
      "Buah": Icons.apple,
      "Bahan Pokok": Icons.shopping_basket,
    };

    final color = colorMap[title] ?? Colors.grey;
    final icon = iconMap[title] ?? Icons.category;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildRecommendationCard({
    required String title,
    dynamic image,
    required String jumlah,
    required String jenis,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          image != null && image is File
              ? ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Image.file(
                  image,
                  height: 90,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
              : const SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.fastfood, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Jenis: $jenis",
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.scale, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Jumlah: $jumlah",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
