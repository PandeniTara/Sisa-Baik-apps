// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sisa_baik/helper/apphelper.dart';
import 'package:sisa_baik/models/donasi.dart';
import '../models/user_model.dart';
import '../preferences/prefs.dart';

class FormSumbangan extends StatefulWidget {
  const FormSumbangan({super.key});

  @override
  State<FormSumbangan> createState() => _FormSumbanganState();
}

class _FormSumbanganState extends State<FormSumbangan> {
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();
  JenisMakanan _selectedJenis = JenisMakanan.makanan;
  File? _imageFile;
  double? _latitude;
  double? _longitude;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final filename = basename(picked.path);
      final savedImage = await File(
        picked.path,
      ).copy('${appDir.path}/$filename');
      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar('🔴 Layanan lokasi tidak aktif');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar('🔴 Izin lokasi ditolak');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackbar('🔴 Izin lokasi ditolak permanen');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  void _showSnackbar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(
      context as BuildContext,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _submit() async {
    final nama = _namaController.text.trim();
    final jumlah = _jumlahController.text.trim();
    final catatan = _catatanController.text.trim();

    if (nama.isEmpty ||
        jumlah.isEmpty ||
        catatan.isEmpty ||
        _imageFile == null) {
      _showSnackbar('❌ Harap isi semua kolom dan unggah gambar');
      return;
    }

    await _getLocation();

    if (_latitude == null || _longitude == null) {
      _showSnackbar('❌ Gagal mendapatkan lokasi');
      return;
    }

    final userId = await Prefs.getUserId();
    if (userId == null) {
      _showSnackbar('❌ Gagal mendapatkan ID user');
      return;
    }

    final newDonasi = Donasi(
      nama: nama,
      jumlah: jumlah,
      catatan: catatan,
      jenisMakanan: _selectedJenis,
      imagePath: _imageFile!.path,
      latitude: _latitude,
      longitude: _longitude,
      userId: userId,
    );

    try {
      await AppDatabase().insertDonasi(newDonasi);

      final db = AppDatabase();
      final totalJumlah = await db.sumJumlahDonasiByUserId(userId);

      User? user = await db.getUserById(userId);
      if (user != null) {
        final updatedUser = user.copyWith(
          totalSumbangan: totalJumlah.toInt(),
          totalPoin: user.totalPoin + 10,
        );
        await db.updateUser(updatedUser);
      }

      final updatedUser = await AppDatabase().getUserById(userId);
      print('✅ Total Sumbangan: ${updatedUser?.totalSumbangan}');
      print('✅ Total Poin: ${updatedUser?.totalPoin}');

      _showSnackbar('✅ Sumbangan berhasil disimpan', color: Colors.green);

      if (mounted) {
        Navigator.pop(context as BuildContext, true);
      }
    } catch (e) {
      print('❌ Gagal menyimpan data: $e');
      _showSnackbar('❌ Terjadi kesalahan saat menyimpan data');
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Sumbangan"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: "Nama Makanan",
                    prefixIcon: Icon(Icons.fastfood),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Jumlah (Kg / Pcs)",
                    prefixIcon: Icon(Icons.numbers),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _catatanController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Catatan",
                    prefixIcon: Icon(Icons.note_alt_outlined),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<JenisMakanan>(
                  value: _selectedJenis,
                  decoration: const InputDecoration(
                    labelText: "Jenis Makanan",
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(),
                  ),
                  items:
                      JenisMakanan.values.map((jenis) {
                        return DropdownMenuItem(
                          value: jenis,
                          child: Text(jenis.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedJenis = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih Gambar dari Galeri"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send),
                  label: const Text("Kirim Sumbangan"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
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
