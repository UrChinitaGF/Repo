import 'package:flutter/material.dart';

import '../boxes.dart';
import '../models/task.dart';
import 'home_screen.dart';

/// Used for both adding (task == null) and editing (task != null).
class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String _priority = 'Medium';
  String _category = 'School';
  bool _isDone = false;

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _categories = ['School', 'Work', 'Personal', 'Others'];

  bool get _isEditing => widget.task != null;

  
  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _date = task.date;
      _time = TimeOfDay.fromDateTime(task.date);
      _priority = task.priority;
      _category = task.category;
      _isDone = task.isDone;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  void _save() {
    // Validation
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    // Combine the picked date and time into one DateTime
    final dateTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    if (_isEditing) {
      // UPDATE
      final task = widget.task!;
      task.title = title;
      task.description = description;
      task.date = dateTime;
      task.priority = _priority;
      task.category = _category;
      task.isDone = _isDone;
      task.save();
    } else {
      // CREATE
      Boxes.tasks.add(
        Task(
          title: title,
          description: description,
          date: dateTime,
          priority: _priority,
          category: _category,
          isDone: _isDone,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final selected = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Task title cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 2. Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Date
            ListTile(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text(formatDate(selected)),
              trailing: const Text('Change'),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),

            // 4. Time
            ListTile(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              leading: const Icon(Icons.access_time),
              title: Text(formatTime(selected)),
              trailing: const Text('Change'),
              onTap: _pickTime,
            ),
            const SizedBox(height: 16),

            // 5. Priority
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: _priorities
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) => setState(() => _priority = value!),
            ),
            const SizedBox(height: 16),

            // 6. Category
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 16),

            // 7. Status
            SwitchListTile(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              title: const Text('Mark as done'),
              value: _isDone,
              onChanged: (value) => setState(() => _isDone = value),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save Changes' : 'Add Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
