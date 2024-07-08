import 'package:flutter/material.dart';
import 'package:todo_app_sqflite/db_helper.dart';
import 'package:todo_app_sqflite/notes.dart';

class NotesProvider with ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();
  late List<NotesModel> _notesList = [];
  bool _isLoading = false;

  List<NotesModel> get notesList => _notesList;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    _notesList = await _dbHelper.getNotesList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOrUpdateTask(NotesModel task, String operation) async {
    if (operation == 'insert') {
      await _dbHelper.insert(task);
    } else if (operation == 'update') {
      await _dbHelper.update(task);
    }
    await loadNotes();
    print('Task added/updated');
  }

  Future<void> deleteTask(int id) async {
    await _dbHelper.delete(id);
    await loadNotes();
  }
}
