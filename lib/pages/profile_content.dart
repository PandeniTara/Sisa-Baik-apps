// ignore_for_file: unused_local_variable, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sisa_baik/helper/apphelper.dart';
import 'package:sisa_baik/login_page.dart';
import 'package:sisa_baik/models/user_model.dart';
import 'package:sisa_baik/preferences/prefs.dart';

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

  Future<void> _loadUser() async {
    final id = await Prefs.getUserId();
    if (id != null) {
      final user = await AppDatabase().getUserById(id);
      final total = await AppDatabase().sumJumlahDonasiByUserId(id);
      final updatedUser = user!.copyWith(totalSumbangan: total.toInt());
      setState(() {
        _user = updatedUser;
      });
    }
  }

  Future<void> _editProfile() async {
    if (_user == null) return;

    final namaController = TextEditingController(text: _user!.nama);
    final noHpController = TextEditingController(text: _user!.noHp ?? '');
    String? fotoPath = _user!.foto;

    final result = await showModalBottomSheet<bool>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Profil',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
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
                  radius: 45,
                  backgroundImage:
                      fotoPath != null ? FileImage(File(fotoPath!)) : null,
                  child:
                      fotoPath == null
                          ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white70,
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noHpController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Nomor HP",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text("Batal", style: GoogleFonts.poppins()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final updatedUser = _user!.copyWith(
                          nama: namaController.text,
                          noHp: noHpController.text,
                          foto: fotoPath,
                        );
                        await AppDatabase().updateUser(updatedUser);
                        Navigator.pop(context, true);

                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                contentPadding: const EdgeInsets.all(24),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Profil berhasil diperbarui!",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Oke",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Simpan",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (result == true) _loadUser();
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
                        _loadUser();
                      } catch (_) {}
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false,
      ),
      body:
          _user == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _user!.foto != null
                              ? FileImage(File(_user!.foto!))
                              : null,
                      child:
                          _user!.foto == null
                              ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white70,
                              )
                              : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _user!.nama,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: _editProfile,
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text("Edit Profil", style: GoogleFonts.poppins()),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildProfileCard(
                      Icons.phone,
                      Colors.blueAccent,
                      "No. HP",
                      _user!.noHp ?? "-",
                    ),
                    const SizedBox(height: 12),
                    _buildProfileCard(
                      Icons.monetization_on,
                      Colors.orangeAccent,
                      "Total Sumbangan",
                      "${_user!.totalSumbangan} Kg",
                    ),
                    const SizedBox(height: 12),
                    _buildProfileCard(
                      Icons.star,
                      Colors.amber,
                      "Total Poin",
                      "${_user!.totalPoin}",
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _scanQRCode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text("Scan QR", style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[100],
                        foregroundColor: Colors.green[900],
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: Text("Logout", style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[100],
                        foregroundColor: Colors.red[900],
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileCard(
    IconData icon,
    Color color,
    String title,
    String value,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
