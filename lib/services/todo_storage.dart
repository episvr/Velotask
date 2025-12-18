import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velotask/models/tag.dart';
import 'package:velotask/models/todo.dart';

class TodoStorage {
  static Isar? _isar;

  Future<void> _init() async {
    if (_isar != null && _isar!.isOpen) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([TodoSchema, TagSchema], directory: dir.path);

    // Seed default tags if empty
    final count = await _isar!.tags.count();
    if (count == 0) {
      await _isar!.writeTxn(() async {
        await _isar!.tags.putAll([
          Tag(name: 'TDL', color: '#2196F3'), // Blue
          Tag(name: 'DDL', color: '#F44336'), // Red
          Tag(name: 'WTD', color: '#FFC107'), // Amber
        ]);
      });
    }
  }

  Future<List<Todo>> loadTodos() async {
    await _init();
    return await _isar!.todos.where().findAll();
  }

  Future<List<Tag>> loadTags() async {
    await _init();
    return await _isar!.tags.where().findAll();
  }

  Future<void> addTag(Tag tag) async {
    await _init();
    await _isar!.writeTxn(() async {
      await _isar!.tags.put(tag);
    });
  }

  Future<void> deleteTag(Id id) async {
    await _init();
    await _isar!.writeTxn(() async {
      await _isar!.tags.delete(id);
    });
  }

  Future<void> addTodo(Todo todo) async {
    await _init();
    await _isar!.writeTxn(() async {
      await _isar!.todos.put(todo);
      await todo.tags.save();
    });
  }

  Future<void> updateTodo(Todo todo) async {
    await _init();
    await _isar!.writeTxn(() async {
      await _isar!.todos.put(todo);
      await todo.tags.save();
    });
  }

  Future<void> deleteTodo(Id id) async {
    await _init();
    await _isar!.writeTxn(() async {
      await _isar!.todos.delete(id);
    });
  }
}
