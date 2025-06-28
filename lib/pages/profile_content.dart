// ignore_for_file: unused_import, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sisa_baik/helper/apphelper.dart';
import 'package:sisa_baik/login_page.dart';
import 'package:sisa_baik/helper/sumbangan_db.dart';
import 'package:sisa_baik/helper/user.dart';
import 'package:sisa_baik/models/user_model.dart';
import 'package:sisa_baik/pages/form_content.dart';
import 'package:sisa_baik/preferences/prefs.dart';
import 'package:sisa_baik/user_test.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUser(); // ⬅️ ini akan dipanggil setiap halaman muncul kembali
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

  Future<void> _editProfile() async {
    final namaController = TextEditingController(text: _user?.nama ?? '');
    final noHpController = TextEditingController(text: _user?.noHp ?? '');
    String? fotoPath = _user?.foto;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() {
                      fotoPath = picked.path;
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      fotoPath != null ? FileImage(File(fotoPath!)) : null,
                  child:
                      fotoPath == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              TextField(
                controller: noHpController,
                decoration: const InputDecoration(labelText: 'No. HP'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedUser = _user!.copyWith(
                  nama: namaController.text,
                  noHp: noHpController.text,
                  foto: fotoPath,
                );

                await AppDatabase().updateUser(updatedUser);
                Navigator.pop(context, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _loadUser(); // refresh setelah update
    }
  }

  Future<void> _scanQRCode() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Scan QR Code"),
            content: SizedBox(
              height: 300,
              width: 300,
              child: MobileScanner(
                fit: BoxFit.contain,
                onDetect: (capture) async {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String? code = barcodes.first.rawValue;
                    if (code != null && context.mounted) {
                      Navigator.pop(context);
                      try {
                        final data = jsonDecode(code);
                        final int id = data['id'];

                        final db = AppDatabase();
                        final deleted = await db.deleteDonasi(id);

                        if (deleted > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Sumbangan berhasil dihapus."),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadUser(); // refresh user setelah hapus sumbangan
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Data tidak ditemukan."),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("QR tidak valid."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ),
          ),
    );
  }

  Future<void> _logout() async {
    await Prefs.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.black,
      ),
      body:
          _user == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _user!.foto != null
                              ? FileImage(File(_user!.foto!))
                              : null,
                      child:
                          _user!.foto == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _user!.nama,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${_user!.username}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextButton.icon(
                      onPressed: _editProfile,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Edit Profil"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildRow(
                              Icons.phone,
                              "No. HP",
                              _user!.noHp ?? "-",
                            ),
                            _buildRow(
                              Icons.monetization_on,
                              "Total Sumbangan",
                              "${_user!.totalSumbangan} Kg",
                            ),
                            _buildRow(
                              Icons.star,
                              "Total Poin",
                              "${_user!.totalPoin}",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _scanQRCode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("Scan QR"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[100],
                        foregroundColor: Colors.green[900],
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[100],
                        foregroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
