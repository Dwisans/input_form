import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../models/task_model.dart';
import '../../repositories/task_repository.dart';
import '../../widgets/task_card.dart';
import '../../widgets/add_edit_task_dialog.dart';
import '../settings/settings_screen.dart';
import 'dart:async'; // Tambahkan untuk Timer

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final TaskRepository _repo = TaskRepository();
  List<Task> _allTasks = [];
  bool _isLoading = true;
  String _selectedPriority = 'Semua';
  bool _isAscending = true;

  // Variabel untuk kontrol notifikasi kustom
  bool _showToast = false;
  String _toastMessage = "";
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final data = await _repo.getTasks();
      if (mounted)
        setState(() {
          _allTasks = data;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // FUNGSI NOTIFIKASI KUSTOM (Ganti SnackBar)
  void _showCustomToast(String message) {
    _toastTimer?.cancel(); // Hapus timer sebelumnya jika ada
    setState(() {
      _toastMessage = message;
      _showToast = true;
    });

    // Hilangkan notifikasi otomatis setelah 2 detik
    _toastTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  void _deleteTask(Task task) async {
    final int deletedIndex = _allTasks.indexOf(task);
    setState(() => _allTasks.removeWhere((t) => t.id == task.id));
    await _repo.saveTasks(_allTasks);

    // Panggil notifikasi kustom
    _showCustomToast("${task.title} berhasil dihapus");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TodoFlow",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectedIndex != 2)
            IconButton(
              icon: Icon(_isAscending ? Icons.calendar_month : Icons.history),
              onPressed: () => setState(() => _isAscending = !_isAscending),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              // Stack digunakan untuk menaruh notifikasi di atas list
              children: [
                Column(
                  children: [
                    if (_selectedIndex != 2) _buildFilterBar(),
                    Expanded(
                      child: _selectedIndex == 2
                          ? const SettingsScreen()
                          : _buildTaskListView(_selectedIndex == 1),
                    ),
                  ],
                ),

                // UI NOTIFIKASI KUSTOM (Mengambang di bawah)
                if (_showToast)
                  Positioned(
                    bottom: 110, // Di atas Navbar
                    left: 30,
                    right: 30,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _showToast ? 1.0 : 0.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          _toastMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: _buildFloatingNavbar(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final newTask = await showDialog<Task>(
                  context: context,
                  builder: (_) => AddEditTaskDialog(onSave: (t) => t),
                );
                if (newTask != null) {
                  setState(() => _allTasks.insert(0, newTask));
                  await _repo.saveTasks(_allTasks);
                }
              },
            )
          : null,
    );
  }

  Widget _buildFilterBar() {
    final categories = ['Semua', 'Tinggi', 'Sedang', 'Rendah'];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = _selectedPriority == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedPriority = cat);
              },
              selectedColor: Colors.teal,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskListView(bool isCompleted) {
    var filtered = _allTasks
        .where((t) => t.isCompleted == isCompleted)
        .toList();
    if (_selectedPriority != 'Semua')
      filtered = filtered
          .where((t) => t.priority == _selectedPriority)
          .toList();
    filtered.sort(
      (a, b) => _isAscending
          ? (a.dueDate ?? '9').compareTo(b.dueDate ?? '9')
          : (b.dueDate ?? '').compareTo(a.dueDate ?? ''),
    );

    if (filtered.isEmpty)
      return const Center(
        child: Text("Kosong", style: TextStyle(color: Colors.grey)),
      );

    return ListView.builder(
      itemCount: filtered.length,
      padding: const EdgeInsets.only(bottom: 120),
      itemBuilder: (context, i) {
        final task = filtered[i];
        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteTask(task),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: TaskCard(
            task: task,
            onTap: () async {
              final updated = await showDialog<Task>(
                context: context,
                builder: (_) => AddEditTaskDialog(task: task, onSave: (t) => t),
              );
              if (updated != null) {
                setState(() {
                  int idx = _allTasks.indexWhere((t) => t.id == task.id);
                  if (idx != -1) _allTasks[idx] = updated;
                });
                await _repo.saveTasks(_allTasks);
              }
            },
            onCheckboxChanged: (val) async {
              setState(() => task.isCompleted = val ?? false);
              await _repo.saveTasks(_allTasks);
            },
          ),
        );
      },
    );
  }

  Widget _buildFloatingNavbar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: GNav(
          gap: 8,
          activeColor: Colors.teal,
          selectedIndex: _selectedIndex,
          onTabChange: (i) => setState(() {
            _selectedIndex = i;
            _showToast = false;
          }),
          tabs: const [
            GButton(icon: Icons.list, text: 'Tugas'),
            GButton(icon: Icons.check_circle, text: 'Selesai'),
            GButton(icon: Icons.person, text: 'Profil'),
          ],
        ),
      ),
    );
  }
}
