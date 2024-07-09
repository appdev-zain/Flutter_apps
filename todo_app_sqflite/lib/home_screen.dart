import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'notes_provider.dart';
import 'notes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);

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
      body: notesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notesProvider.notesList.isEmpty
              ? const Center(child: Text('No todos yet'))
              : ListView.builder(
                  itemCount: notesProvider.notesList.length,
                  itemBuilder: (context, index) {
                    final note = notesProvider.notesList[index];
                    return InkWell(
                      onTap: () {
                        _showAddTaskBottomSheet(context, 'update', note);
                      },
                      child: Dismissible(
                        key: Key(note.id.toString()),
                        onDismissed: (direction) {
                          notesProvider.deleteTask(note.id!);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: const Icon(Icons.delete),
                        ),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            title: Text(note.title),
                            subtitle: Text(note.description),
                            trailing: Text(note.dueDate.toString()),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskBottomSheet(context, 'insert');
          notesProvider.loadNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

void _showAddTaskBottomSheet(BuildContext context, String operation,
    [NotesModel? task]) {
  final _formKey = GlobalKey<FormState>();
  String title = task?.title ?? '';
  String description = task?.description ?? '';
  DateTime? dueDate = task?.dueDate;
  Priority priority = task?.priority ?? Priority.Medium;
  TaskCategory category = task != null
      ? TaskCategory.values.firstWhere((e) => e.name == task.category)
      : TaskCategory.other;
  bool reminder = task?.reminder ?? false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      print('showModalBottomSheet : opened');
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'Add New Task',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    'Due Date: ${dueDate != null ? DateFormat.yMd().format(dueDate!) : 'Not set'}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  dueDate = await showDatePicker(
                    context: context,
                    initialDate: dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
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
                  priority = newValue!;
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
                  category = newValue!;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Set Reminder'),
                value: reminder,
                onChanged: (bool value) {
                  reminder = value;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
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
                              'Task ${operation == 'insert' ? 'added' : 'updated'} successfully')),
                    );

                    Provider.of<NotesProvider>(context, listen: false)
                        .addOrUpdateTask(newTask, operation);
                  }
                },
                child: Text(operation == 'insert' ? 'Add Task' : 'Update Task'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
