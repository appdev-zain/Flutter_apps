import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'notes_provider.dart';
import 'notes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load notes when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false).loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              DateFormat('MMMM').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 22,
                fontFamily: 'sans-serif',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              DateFormat(' yyyy').format(DateTime.now()),
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          if (notesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (notesProvider.notesList.isEmpty) {
            return const Center(child: Text('No todos yet'));
          } else {
            return ListView.builder(
              itemCount: notesProvider.notesList.length,
              itemBuilder: (context, index) {
                final note = notesProvider.notesList[index];
                return Dismissible(
                  key: Key(note.id.toString()),
                  onDismissed: (direction) {
                    notesProvider.deleteTask(note.id!);
                  },
                  background: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 8),
                    child: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ListTile(
                          onTap: () =>
                              _showAddTaskBottomSheet(context, 'update', note),
                          leading: const Icon(Icons.task),
                          contentPadding: const EdgeInsets.all(0),
                          title: Text(note.title),
                          subtitle: Text(note.description),
                          trailing: Text(
                            note.dueDate != null
                                ? DateFormat('yyMd').format(note.dueDate!)
                                : 'No date',
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskBottomSheet(context, 'insert');
        },
        tooltip: 'Create Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

void _showAddTaskBottomSheet(BuildContext context, String operation,
    [NotesModel? task]) {
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          String title = task?.title ?? '';
          String description = task?.description ?? '';
          DateTime? dueDate = task?.dueDate;
          Priority priority = task?.priority ?? Priority.medium;
          TaskCategory category = task != null
              ? TaskCategory.values.firstWhere(
                  (e) => e.name == task.category.toString().split('.').last)
              : TaskCategory.other;
          bool reminder = task?.reminder ?? false;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Form(
              key: formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    operation == 'insert' ? 'Add New Task' : 'Edit Task',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onSaved: (value) => title = value!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onSaved: (value) => description = value!,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(
                      'Due Date: ${dueDate != null ? DateFormat.yMd().format(dueDate) : 'Not set'}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null && pickedDate != dueDate) {
                        setState(() {
                          dueDate = pickedDate;
                        });
                      }
                    },
                  ),
                  DropdownButtonFormField<Priority>(
                    value: priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: Priority.values.map((Priority value) {
                      return DropdownMenuItem<Priority>(
                        value: value,
                        child: Text(value.name),
                      );
                    }).toList(),
                    onChanged: (Priority? newValue) {
                      setState(() {
                        priority = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TaskCategory>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: TaskCategory.values.map((TaskCategory value) {
                      return DropdownMenuItem<TaskCategory>(
                        value: value,
                        child: Text(value.name),
                      );
                    }).toList(),
                    onChanged: (TaskCategory? newValue) {
                      setState(() {
                        category = newValue!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        final newTask = NotesModel(
                          id: task?.id,
                          title: title,
                          description: description,
                          dueDate: dueDate,
                          category: category,
                          priority: priority,
                          reminder: reminder,
                        );
                        print('New task $newTask');

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Task ${operation == 'insert' ? 'added' : 'updated'} successfully',
                            ),
                          ),
                        );

                        Provider.of<NotesProvider>(context, listen: false)
                            .addOrUpdateTask(newTask, operation);
                      }
                    },
                    child: Text(
                        operation == 'insert' ? 'Add Task' : 'Update Task'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
