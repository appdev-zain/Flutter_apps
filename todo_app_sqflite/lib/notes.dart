enum Priority { low, medium, high }

enum TaskCategory {
  work,
  personal,
  shopping,
  health,
  finance,
  education,
  home,
  other
}

class NotesModel {
  final int? id;
  final String title;
  final String description;
  DateTime? dueDate;
  final Priority priority;
  final TaskCategory category;
  bool reminder;

  NotesModel({
    this.id,
    required this.title,
    required this.description,
    this.dueDate,
    required this.category,
    required this.priority,
    this.reminder = false,
  });

  NotesModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        description = map['description'],
        dueDate = map['dueDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
            : null,
        category = TaskCategory.values.firstWhere(
            (e) => e.toString() == 'Category.' + map['category'],
            orElse: () => TaskCategory.other),
        priority = Priority.values.firstWhere(
            (e) => e.toString() == 'Priority.' + map['priority'],
            orElse: () => Priority.medium),
        reminder = map['reminder'] == 1;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'category': category.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'reminder': reminder ? 1 : 0,
    };
  }

  NotesModel copy({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskCategory? category,
    Priority? priority,
    bool? reminder,
  }) {
    return NotesModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      reminder: reminder ?? this.reminder,
    );
  }
}
