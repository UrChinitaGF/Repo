import 'package:hive_flutter/hive_flutter.dart';

import 'models/task.dart';

/// Central place for Hive box names and accessors.
class Boxes {
  static const String taskBoxName = 'taskBox';

  /// The box is opened in main(), so it is safe to access synchronously here.
  static Box<Task> get tasks => Hive.box<Task>(taskBoxName);
}
