import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velotask/models/todo.dart';

class TodoStorage {
  static Isar? _isar;

  Future<void> _init() async {
    if (_isar != null && _isar!.isOpen) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([TodoSchema], directory: dir.path);
  }

  Future<List<Todo>> loadTodos() async {
    await _init();
    return await _isar!.todos.where().findAll();
  }

  Future<void> addTodo(Todo todo) async {
    await _init();
    await _isar!.writeTxn(() async {
      await _isar!.todos.put(todo);
    });
  }

  Future<void> updateTodo(Todo todo) async {
    await _init();
    await _isar!.writeTxn(() async {
      await _isar!.todos.put(todo);
    });
  }

  Future<void> deleteTodo(Id id) async {
    await _init();
    await _isar!.writeTxn(() async {
      await _isar!.todos.delete(id);
    });
  }
}
