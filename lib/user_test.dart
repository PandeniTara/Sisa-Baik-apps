import 'package:flutter/material.dart';
import 'package:sisa_baik/helper/apphelper.dart';
import '../models/user_model.dart';
import '../preferences/prefs.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? _user;
  bool _isLoading = true;

  Future<void> _loadUserData() async {
    final userId = await Prefs.getUserId();
    if (userId != null) {
      final user = await AppDatabase().getUserById(userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _user == null
              ? const Center(child: Text("❌ Gagal memuat data pengguna"))
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("👤 Nama: ${_user!.nama}", style: _style),
                    const SizedBox(height: 12),
                    Text("📞 No HP: ${_user!.noHp ?? '-'}", style: _style),
                    const SizedBox(height: 12),
                    Text(
                      "🧺 Total Sumbangan: ${_user!.totalSumbangan}",
                      style: _style,
                    ),
                    const SizedBox(height: 12),
                    Text("⭐ Total Poin: ${_user!.totalPoin}", style: _style),
                  ],
                ),
              ),
    );
  }

  final TextStyle _style = const TextStyle(fontSize: 18);
}
