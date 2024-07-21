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
    try {
      _notesList = await _dbHelper.getNotesList();
      notifyListeners();
    } catch (e) {
      print('Error loading notes: $e');
      // Handle the error appropriately
    }
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

  void deleteAll() async {
    await _dbHelper.deleteAll();
    await loadNotes();
  }
}
