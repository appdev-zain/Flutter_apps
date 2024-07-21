import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_sqflite/db_helper.dart';
import 'notes_provider.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DbHelper();
  await dbHelper.database; // This will ensure the database is initialized
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotesProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
