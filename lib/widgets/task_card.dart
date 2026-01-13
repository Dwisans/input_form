import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheckboxChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onCheckboxChanged,
  });

  Future<void> _onOpenLink(LinkableElement link) async {
    // 1. Logika WhatsApp
    // Mencari pola yang mirip nomor telepon (minimal 10 digit)
    String cleanNumber = link.text.replaceAll(RegExp(r'\D'), '');

    // Cek apakah pola teks menyerupai nomor HP Indonesia
    if (cleanNumber.startsWith('08') || cleanNumber.startsWith('628')) {
      if (cleanNumber.startsWith('0')) {
        cleanNumber = '62${cleanNumber.substring(1)}';
      }
      final waUri = Uri.parse("whatsapp://send?phone=$cleanNumber");
      final waWebUri = Uri.parse("https://wa.me/$cleanNumber");

      if (await canLaunchUrl(waUri)) {
        await launchUrl(waUri);
      } else if (await canLaunchUrl(waWebUri)) {
        await launchUrl(waWebUri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // 2. Logika URL Website Biasa
    final Uri url = Uri.parse(link.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: onCheckboxChanged,
          activeColor: Colors.teal,
          shape: const CircleBorder(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Linkify(
              onOpen: _onOpenLink,
              text: task.description,
              style: const TextStyle(color: Colors.black54),
              linkStyle: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (task.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Tenggat: ${DateFormat('dd MMM yyyy').format(DateTime.parse(task.dueDate!))}",
                  style: const TextStyle(fontSize: 12, color: Colors.teal),
                ),
              ),
          ],
        ),
        trailing: _buildPriorityIndicator(task.priority),
      ),
    );
  }

  Widget _buildPriorityIndicator(String priority) {
    Color color;
    switch (priority) {
      case 'Tinggi':
        color = Colors.red;
        break;
      case 'Sedang':
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
