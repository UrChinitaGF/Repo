import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime date; // stores both the date and the time

  @HiveField(2)
  String description;

  @HiveField(3)
  String priority; // Low, Medium, High

  @HiveField(4)
  String category; // School, Work, Personal, Others

  @HiveField(5)
  bool isDone;

  Task({
    required this.title,
    required this.date,
    this.description = '',
    this.priority = 'Medium',
    this.category = 'School',
    this.isDone = false,
  });
}
