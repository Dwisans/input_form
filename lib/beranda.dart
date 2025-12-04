// beranda.dart
// ignore_for_file: camel_case_types

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Halaman_Utama extends StatefulWidget {
  const Halaman_Utama({super.key});

  @override
  State<Halaman_Utama> createState() => _Halaman_UtamaState();
}

class _Halaman_UtamaState extends State<Halaman_Utama> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _npmController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();

  final List<String> _prodiList = [
    'Informatika',
    'Mesin',
    'Sipil',
    'Arsitektur',
    'Elektro',
    'Akuntansi',
  ];
  final List<String> _kelasList = ['A', 'B', 'C', 'D', 'E'];
  String? _selectedKelas;
  String? _selectedProdi;
  String _jenisKelamin = 'Pria';

  List<Map<String, dynamic>> _items = [];
  static const String _prefsKey = 'submissions';
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _npmController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  // === LOAD & SAVE DATA ===
  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? raw = prefs.getStringList(_prefsKey);
    if (raw != null) {
      setState(() {
        _items = raw.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
      });
    }
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = _items.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList(_prefsKey, raw);
  }

  // === VALIDASI ===
  bool _isValidEmail(String email) {
    if (email.isEmpty) return true;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    if (phone.isEmpty) return true;
    return RegExp(r'^[0-9]{10,15}$').hasMatch(phone.trim());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
  }

  // === ADD / UPDATE ITEM ===
  void _addOrUpdateItem() {
    final nama = _namaController.text.trim();
    final npm = _npmController.text.trim();
    final email = _emailController.text.trim();
    final noHp = _noHpController.text.trim();

    if (nama.isEmpty || npm.isEmpty) {
      _showError('Nama dan NPM wajib diisi!');
      return;
    }

    if (email.isNotEmpty && !_isValidEmail(email)) {
      _showError('Format email salah! Contoh: budi@gmail.com');
      return;
    }

    if (noHp.isNotEmpty && !_isValidPhone(noHp)) {
      _showError('No. HP harus angka dan minimal 10 digit');
      return;
    }

    final item = {
      'nama': nama,
      'alamat': _alamatController.text.trim(),
      'npm': npm,
      'email': email.isEmpty ? '-' : email,
      'noHp': noHp.isEmpty ? '-' : noHp,
      'kelas': _selectedKelas ?? '-',
      'prodi': _selectedProdi ?? '-',
      'jk': _jenisKelamin,
      'createdAt': _editingIndex == null
          ? DateTime.now().toIso8601String()
          : _items[_editingIndex!]['createdAt'],
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (_editingIndex == null) {
      setState(() => _items.insert(0, item));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _items[_editingIndex!] = item;
        _editingIndex = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    }

    _saveAll();
    _clearForm();
  }

  Future<void> _removeItem(int index) async {
    setState(() => _items.removeAt(index));
    await _saveAll();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));
  }

  void _startEdit(int index) {
    final item = _items[index];
    setState(() {
      _editingIndex = index;
      _namaController.text = item['nama'] ?? '';
      _alamatController.text = item['alamat'] ?? '';
      _npmController.text = item['npm'] ?? '';
      _emailController.text = item['email'] == '-' ? '' : item['email'];
      _noHpController.text = item['noHp'] == '-' ? '' : item['noHp'];
      _selectedKelas = item['kelas'] != '-' ? item['kelas'] : null;
      _selectedProdi = item['prodi'] != '-' ? item['prodi'] : null;
      _jenisKelamin = item['jk'] ?? 'Pria';
    });
  }

  void _clearForm() {
    _namaController.clear();
    _alamatController.clear();
    _npmController.clear();
    _emailController.clear();
    _noHpController.clear();
    setState(() {
      _selectedKelas = null;
      _selectedProdi = null;
      _jenisKelamin = 'Pria';
      _editingIndex = null;
    });
  }

  void _showDetail(Map<String, dynamic> item, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item['nama']),
        content: SingleChildScrollView(
          child: Text(
            'NPM           : ${item['npm']}\n'
            'Email         : ${item['email']}\n'
            'No. HP        : ${item['noHp']}\n'
            'Alamat        : ${item['alamat']}\n'
            'Kelas         : ${item['kelas']}\n'
            'Prodi         : ${item['prodi']}\n'
            'Jenis Kelamin : ${item['jk']}\n'
            'Dibuat        : ${item['createdAt'].substring(0, 19)}\n'
            'Diperbarui    : ${item['updatedAt']?.substring(0, 19) ?? '-'}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startEdit(index);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeItem(index);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Form Input
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _alamatController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _npmController,
                      decoration: const InputDecoration(
                        labelText: 'NPM',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email (opsional)',
                        hintText: 'contoh: nama@student.ac.id',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noHpController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'No. HP (opsional)',
                        hintText: '081234567890',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedKelas,
                      hint: const Text('Pilih Kelas'),
                      decoration: const InputDecoration(
                        labelText: 'Kelas',
                        prefixIcon: Icon(Icons.class_),
                        border: OutlineInputBorder(),
                      ),
                      items: _kelasList
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedKelas = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedProdi,
                      hint: const Text('Pilih Program Studi'),
                      decoration: const InputDecoration(
                        labelText: 'Program Studi',
                        prefixIcon: Icon(Icons.school),
                        border: OutlineInputBorder(),
                      ),
                      items: _prodiList
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedProdi = v),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Jenis Kelamin: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Radio<String>(
                          value: 'Pria',
                          groupValue: _jenisKelamin,
                          onChanged: (v) => setState(() => _jenisKelamin = v!),
                        ),
                        const Text('Pria'),
                        const SizedBox(width: 20),
                        Radio<String>(
                          value: 'Perempuan',
                          groupValue: _jenisKelamin,
                          onChanged: (v) => setState(() => _jenisKelamin = v!),
                        ),
                        const Text('Perempuan'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addOrUpdateItem,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(
                      _editingIndex == null ? 'TAMBAH DATA' : 'UPDATE DATA',
                    ),
                  ),
                ),
                if (_editingIndex != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _clearForm,
                    child: const Text('Batal', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),

            // List Data
            Expanded(
              flex: 2,
              child: _items.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada data mahasiswa',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (ctx, i) {
                        final item = _items[i];
                        return Dismissible(
                          key: Key(item['createdAt']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          onDismissed: (_) => _removeItem(i),
                          child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                child: Text(
                                  item['kelas'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                item['nama'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${item['npm']} • ${item['prodi']}',
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                              ),
                              onTap: () => _showDetail(item, i),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
