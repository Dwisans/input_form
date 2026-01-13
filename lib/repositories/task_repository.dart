import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskRepository {
  static const String _key = 'todo_tasks';
  static final TaskRepository _instance = TaskRepository._internal();
  factory TaskRepository() => _instance;
  TaskRepository._internal();

  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? raw = prefs.getStringList(_key);
    if (raw == null) return [];
    return raw.map((e) => Task.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = tasks.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }

  String generateId() => const Uuid().v4();
}