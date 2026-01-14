import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';

class AddEditTaskDialog extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;

  const AddEditTaskDialog({super.key, this.task, required this.onSave});

  @override
  State<AddEditTaskDialog> createState() => _AddEditTaskDialogState();
}

class _AddEditTaskDialogState extends State<AddEditTaskDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'Rendah';
  final _priorities = ['Rendah', 'Sedang', 'Tinggi'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _dueDate = widget.task!.dueDate != null
          ? DateTime.parse(widget.task!.dueDate!)
          : null;
      _priority = widget.task!.priority;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      // Menyesuaikan tema kalender agar Teal
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.teal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    if (_titleController.text.isEmpty) return;

    final task = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descController.text,
      dueDate: _dueDate?.toIso8601String(),
      priority: _priority,
      isCompleted: widget.task?.isCompleted ?? false,
      createdAt: widget.task?.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    Navigator.pop(context, task);
  }

  // Helper untuk styling TextField agar konsisten
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal),
      labelStyle: const TextStyle(color: Colors.teal),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: Row(
        children: [
          Icon(
            widget.task == null ? Icons.add_task : Icons.edit_note,
            color: Colors.teal,
          ),
          const SizedBox(width: 10),
          Text(
            widget.task == null ? 'Tambah Task' : 'Edit Task',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: _buildInputDecoration('Judul Task *', Icons.title),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: _buildInputDecoration('Deskripsi', Icons.description),
            ),
            const SizedBox(height: 16),
            // Tombol Tanggal yang lebih menarik
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.teal),
                    const SizedBox(width: 12),
                    Text(
                      _dueDate == null
                          ? 'Pilih Tanggal Selesai'
                          : DateFormat('dd MMMM yyyy').format(_dueDate!),
                      style: TextStyle(
                        color: _dueDate == null
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              items: _priorities
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _priority = v!),
              decoration: _buildInputDecoration(
                'Prioritas',
                Icons.low_priority,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text('Simpan Task'),
        ),
      ],
    );
  }
}
