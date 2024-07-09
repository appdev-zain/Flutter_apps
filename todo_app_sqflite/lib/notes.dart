import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum Priority { Low, Medium, High }

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
  bool reminder = false;

  NotesModel({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    required this.priority,
    required this.reminder,
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
            orElse: () => Priority.Medium),
        reminder = map['reminder'] == 1 ? true : false;

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
}
