import 'package:flutter/material.dart';
import 'package:todo_app_sqflite/db_helper.dart';
import 'package:todo_app_sqflite/notes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DbHelper? dbHelper;
  late Future<List<NotesModel>> notesList;
  loadData() async {
    setState(() {
      notesList = dbHelper!.getNotesList();
    });
  }

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Todo List App'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                dbHelper!
                    .insert(NotesModel(
                  title: 'First Todo Item',
                  description: 'This si the first todo item',
                  age: 20,
                  email: 'appdev.zain@gmail.com',
                ))
                    .then((value) {
                  print('Todo item inserted');
                  setState(() {
                    notesList = dbHelper!.getNotesList();
                  });
                }).catchError((error) {
                  print('Error inserting todo item: $error');
                });
              },
            ),
          ],
        ),
        drawer: const _drawer(),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  future: notesList,
                  builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No todos yet'));
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              dbHelper!.update(NotesModel(
                                  title: 'First Flutter note',
                                  description: "description",
                                  age: 22,
                                  email: 'email'));
                              setState(() {
                                notesList = dbHelper!.getNotesList();
                              });
                            },
                            child: Dismissible(
                              onDismissed: (direction) {
                                dbHelper!
                                    .delete(snapshot.data![index].id!)
                                    .then((value) {
                                  print('Todo item deleted');
                                  setState(() {
                                    notesList = dbHelper!.getNotesList();
                                  });
                                }).catchError((error) {
                                  print('Error deleting todo item: $error');
                                });
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                child: const Icon(Icons.delete),
                              ),
                              key: Key(snapshot.data![index].id.toString()),
                              child: Card(
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  title: Text(
                                      snapshot.data![index].title.toString()),
                                  subtitle: Text(snapshot
                                      .data![index].description
                                      .toString()),
                                  trailing: Text(
                                      snapshot.data![index].age.toString()),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class _drawer extends StatelessWidget {
  const _drawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
