import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

import 'notes.dart';

class DbHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/app_todoList.db';

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE TODOLISTS 
        (id INTEGER PRIMARY KEY AUTOINCREMENT, 
        title TEXT NOT NULL, 
        description TEXT NOT NULL, 
        dueDate INTEGER NOT NULL,
        category TEXT NOT NULL,
        priority TEXT NOT NULL,
        reminder INTEGER NOT NULL
        )''');
  }

  Future<NotesModel> insert(NotesModel notesModel) async {
    var dbClient = await db;
    await dbClient!.insert('TODOLISTS', notesModel.toMap());
    return notesModel;
  }

  Future<List<NotesModel>> getNotesList() async {
    var dbClient = await db;
    final List<Map<String, dynamic>> queryResult =
        await dbClient!.query('TODOLISTS');
    return queryResult.map((e) => NotesModel.fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient!
        .delete('TODOLISTS', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(NotesModel notesModel) async {
    var dbClient = await db;
    return await dbClient!.update('TODOLISTS', notesModel.toMap(),
        where: 'id = ?', whereArgs: [notesModel.id]);
  }
}
