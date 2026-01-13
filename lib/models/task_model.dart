class Task {
  String id;
  String title;
  String description;
  String? dueDate; // ISO string
  String priority; // Rendah, Sedang, Tinggi
  bool isCompleted;
  String createdAt;
  String updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = 'Rendah',
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate,
        'priority': priority,
        'isCompleted': isCompleted,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        dueDate: json['dueDate'],
        priority: json['priority'] ?? 'Rendah',
        isCompleted: json['isCompleted'] ?? false,
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );
}