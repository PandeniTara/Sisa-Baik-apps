// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:sisa_baik/pages/scan_qr_page.dart';
import 'pages/home_content.dart';
import 'pages/sumbangan_content.dart';
import 'pages/form_content.dart';
import 'pages/profile_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  double _scale = 1.0;

  final List<Widget> _pages = [
    const HomeContent(),
    const SumbanganContent(),
    const FormSumbangan(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onScanPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // ← Penting: mencegah tombol naik saat keyboard muncul
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.85),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: _onScanPressed,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          child: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.qr_code_scanner, size: 30),
            onPressed: _onScanPressed,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.white,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(index: 0, icon: Icons.home, label: 'Beranda'),
              _buildNavItem(
                index: 1,
                icon: Icons.volunteer_activism,
                label: 'Sumbangan',
              ),
              const SizedBox(width: 40), // ruang untuk FAB
              _buildNavItem(index: 2, icon: Icons.edit_note, label: 'Form'),
              _buildNavItem(index: 3, icon: Icons.person, label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () => _onItemTapped(index),
      child: AnimatedScale(
        scale: _selectedIndex == index ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
