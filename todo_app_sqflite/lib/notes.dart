class NotesModel {
  final int? id;
  final String title;
  final String description;
  DateTime? dueDate;
  String priority = 'Medium';
  String category = '';
  bool reminder = false;

/*
  DateTime? dueDate;
  String priority = 'Medium';
  String category = '';
  bool reminder = false;
*/

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
        dueDate = map['dueDate'],
        category = map['category'],
        priority = map['priority'],
        reminder = map['reminder'] == 1 ? true : false;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'category': category,
      'priority': priority,
      'reminder': reminder ? 1 : 0,
    };
  }
}
