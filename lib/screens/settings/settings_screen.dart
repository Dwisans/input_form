import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/task_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TaskRepository _repo = TaskRepository();
  int _totalTasks = 0;
  int _completedTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final tasks = await _repo.getTasks();
    if (mounted) {
      setState(() {
        _totalTasks = tasks.length;
        _completedTasks = tasks.where((t) => t.isCompleted).length;
      });
    }
  }

  // Fungsi Ambil Gambar dari Galeri & Simpan ke AuthProvider
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Kompres gambar agar tidak berat saat disimpan
    );

    if (image != null) {
      // Panggil fungsi updateProfilePic dari AuthProvider Anda
      // Kita simpan path filenya
      Provider.of<AuthProvider>(context, listen: false)
          .updateProfilePic(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data sesuai dengan getter di AuthProvider Anda
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // HEADER: Profil & Ganti Foto
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    // Logika tampilan: Cek apakah path itu file lokal atau URL internet
                    backgroundImage: auth.profilePic.startsWith('http')
                        ? NetworkImage(auth.profilePic) as ImageProvider
                        : FileImage(File(auth.profilePic)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              auth.username, // Menggunakan getter 'username'
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Dwiky Personal Account", // Placeholder karena email tidak ada di AuthProvider
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // SECTION: Statistik
            Row(
              children: [
                _buildStatCard("Total Tugas", _totalTasks.toString(), Colors.blue),
                const SizedBox(width: 15),
                _buildStatCard("Selesai", _completedTasks.toString(), Colors.green),
              ],
            ),
            
            const SizedBox(height: 30),

            // SECTION: Menu Pengaturan
            _buildMenuTile(Icons.notifications_none, "Notifikasi", () {}),
            _buildMenuTile(Icons.lock_outline, "Keamanan", () {}),
            _buildMenuTile(Icons.info_outline, "Tentang Aplikasi", () {}),
            const Divider(height: 40),
            _buildMenuTile(
              Icons.logout, 
              "Keluar", 
              () => auth.logout(), 
              color: Colors.red
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {Color color = Colors.black87}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}