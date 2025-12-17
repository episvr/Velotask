import 'package:isar/isar.dart';

part 'todo.g.dart';

enum TaskType { ddl, tdl, wtd }

@collection
class Todo {
  Id id = Isar.autoIncrement;

  String title;
  String description;
  bool isCompleted;
  DateTime? createdAt;
  DateTime? startDate;
  DateTime? ddl;
  int importance; // 0: Low, 1: Normal, 2: High
  @enumerated
  TaskType taskType;

  Todo({
    this.id = Isar.autoIncrement,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.createdAt,
    this.startDate,
    this.ddl,
    this.importance = 1,
    this.taskType = TaskType.tdl,
  });

  // 复制方法
  Todo copyWith({
    Id? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? ddl,
    int? importance,
    TaskType? taskType,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      ddl: ddl ?? this.ddl,
      importance: importance ?? this.importance,
      taskType: taskType ?? this.taskType,
    );
  }
}
