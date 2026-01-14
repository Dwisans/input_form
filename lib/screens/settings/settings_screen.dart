import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../main.dart';
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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (image != null) {
        if (mounted) {
          Provider.of<AuthProvider>(
            context,
            listen: false,
          ).updateProfilePic(image.path);
        }
      }
    } on PlatformException catch (e) {
      // Menangani error channel image_picker
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: Pastikan aplikasi sudah direstart (bukan hot reload)",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.teal.withOpacity(0.1),
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
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              auth.username,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Dwiky Personal Account",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                _buildStatCard(
                  "Total Tugas",
                  _totalTasks.toString(),
                  Colors.blue,
                ),
                const SizedBox(width: 15),
                _buildStatCard(
                  "Selesai",
                  _completedTasks.toString(),
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildMenuTile(Icons.notifications_none, "Notifikasi", () {}),
            _buildMenuTile(Icons.lock_outline, "Keamanan", () {}),
            _buildMenuTile(Icons.info_outline, "Tentang Aplikasi", () {}),
            const Divider(height: 40),
            _buildMenuTile(
              Icons.logout,
              "Keluar",
              () => _handleLogout(context, auth),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  // FUNGSI LOGOUT DENGAN NAVIGASI
  void _handleLogout(BuildContext context, AuthProvider auth) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await auth.logout();

      // GUNAKAN NAVIGASI GLOBAL
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
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
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color = Colors.black87,
  }) {
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
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
