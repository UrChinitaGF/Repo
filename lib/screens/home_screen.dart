import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../boxes.dart';
import '../models/task.dart';
import 'task_form_screen.dart';

String formatDate(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

String formatTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final period = d.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

Color priorityColor(String priority) {
  switch (priority) {
    case 'High':
      return Colors.red;
    case 'Low':
      return Colors.green;
    default:
      return Colors.orange;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final box = Boxes.tasks;
    if (box.isEmpty) {
      final initialTasks = [
        Task(
            title: '[Task 1] FInish the lab act 1',
            description: 'FInishing the CRUD',
            date: DateTime.now(),
            priority: 'High',
            category: 'Work',
            isDone: false),
        Task(
            title: '[Task 2] Add Dependency of HIve',
            description: 'Add dependencies hive: ^2.2.3 and hive_flutter: ^1.1.0',
            date: DateTime.now(),
            priority: 'High',
            category: 'Work',
            isDone: false),
        Task(
            title: '[Task 3] Add Dev dependencies of hive',
            description: 'Add dev_dependencies hive_generator: ^2.0.0 and build_runner: ^2.3.3',
            date: DateTime.now(),
            priority: 'Low',
            category: 'Health',
            isDone: false),
        Task(
            title: '[Task 4] Add 7 textfields or feature',
            description: 'Add First three Features of the app: Title, Description, Date',
            date: DateTime.now(),
            priority: 'High',
            category: 'Work',
            isDone: false),
        Task(
            title: '[Task 5] Add 4 more textfields or feature',
            description: 'Add last feature: Time, Priority, Category, and isDone',
            date: DateTime.now(),
            priority: 'High',
            category: 'Work',
            isDone: false),
        Task(
            title: '[Task 6] Dentis Appointment',
            description: '',
            date: DateTime(2026, 10, 7, 10, 30),
            priority: 'Low',
            category: 'Health',
            isDone: false),
        Task(
            title: '[Task 7] ',
            description: 'Description 7',
            date: DateTime.now(),
            priority: 'High',
            category: 'Work',
            isDone: false),
      ];
      box.addAll(initialTasks);
    }
  }

  void _openForm(BuildContext context, {Task? task}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      // CREATE
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),

      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: Boxes.tasks.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No tasks yet. Tap + to add one.'));
          }

          final tasks = box.values.toList();

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              // DELETE - swipe to remove
              return Dismissible(
                key: ValueKey(task.key),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  final title = task.title;
                  task.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"$title" deleted')),
                  );
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    // UPDATE - tick the checkbox to mark as done
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (value) {
                        task.isDone = value ?? false;
                        task.save();
                      },
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description.isNotEmpty) Text(task.description),
                        Text(
                            '${formatDate(task.date)}  •  ${formatTime(task.date)}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              task.priority,
                              style: TextStyle(
                                color: priorityColor(task.priority),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('  •  ${task.category}'),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    // UPDATE - tap the edit icon
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(context, task: task),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
