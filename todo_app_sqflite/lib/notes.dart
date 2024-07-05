class NotesModel {
  final int? id;
  final String title;
  final String description;
  final String email;
  final int age;

  NotesModel({
    this.id,
    required this.title,
    required this.description,
    required this.age,
    required this.email,
  });

  NotesModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        description = map['description'],
        age = map['age'],
        email = map['email'];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'age': age,
      'email': email,
    };
  }
}
