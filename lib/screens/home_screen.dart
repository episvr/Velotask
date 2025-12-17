import 'dart:async';
import 'package:flutter/material.dart';
import 'package:velotask/models/todo.dart';
import 'package:velotask/models/todo_filter.dart';
import 'package:velotask/services/todo_storage.dart';
import 'package:velotask/widgets/add_todo_dialog.dart';
import 'package:velotask/widgets/empty_state.dart';
import 'package:velotask/widgets/filter_section.dart';
import 'package:velotask/widgets/home_app_bar.dart';
import 'package:velotask/widgets/progress_header.dart';
import 'package:velotask/widgets/todo_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> todos = [];
  bool _isLoading = true;
  final TodoStorage _storage = TodoStorage();
  TodoFilter _filter = TodoFilter.active;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final loadedTodos = await _storage.loadTodos();
    if (mounted) {
      setState(() {
        todos = loadedTodos;
        _isLoading = false;
      });
    }
  }

  Future<void> _addTodo(
    String title,
    String desc,
    DateTime? startDate,
    DateTime? ddl,
    int importance,
    TaskType taskType,
  ) async {
    if (title.isEmpty) return;

    final newTodo = Todo(
      title: title,
      description: desc,
      startDate: startDate,
      ddl: ddl,
      importance: importance,
      taskType: taskType,
    );

    await _storage.addTodo(newTodo);
    if (mounted) {
      setState(() {
        todos.add(newTodo);
      });
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    await _storage.deleteTodo(todo.id);
    if (mounted) {
      setState(() {
        todos.removeWhere((t) => t.id == todo.id);
      });
    }
  }

  Future<void> _toggleTodo(Todo todo) async {
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    if (mounted) {
      setState(() {
        final index = todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          todos[index] = updatedTodo;
        }
      });
    }
    await _storage.updateTodo(updatedTodo);
  }

  Future<void> _editTodo(Todo todo) async {
    showDialog(
      context: context,
      builder: (context) => AddTodoDialog(
        todo: todo,
        onAdd: (title, desc, startDate, ddl, importance, taskType) async {
          final updatedTodo = todo.copyWith(
            title: title,
            description: desc,
            startDate: startDate,
            ddl: ddl,
            importance: importance,
            taskType: taskType,
          );
          if (mounted) {
            setState(() {
              final index = todos.indexWhere((t) => t.id == todo.id);
              if (index != -1) {
                todos[index] = updatedTodo;
              }
            });
          }
          await _storage.updateTodo(updatedTodo);
        },
      ),
    );
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTodoDialog(onAdd: _addTodo),
    );
  }

  List<Todo> get _filteredTodos {
    switch (_filter) {
      case TodoFilter.active:
        return todos.where((t) => !t.isCompleted).toList();
      case TodoFilter.completed:
        return todos.where((t) => t.isCompleted).toList();
      case TodoFilter.highPriority:
        return todos.where((t) => !t.isCompleted && t.importance == 2).toList();
      case TodoFilter.ddl:
        return todos
            .where((t) => !t.isCompleted && t.taskType == TaskType.ddl)
            .toList();
      case TodoFilter.tdl:
        return todos
            .where((t) => !t.isCompleted && t.taskType == TaskType.tdl)
            .toList();
      case TodoFilter.wtd:
        return todos
            .where((t) => !t.isCompleted && t.taskType == TaskType.wtd)
            .toList();
      case TodoFilter.all:
        return todos;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredTodos;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          HomeAppBar(todos: todos),
          ProgressHeader(todos: todos),
          FilterSection(
            currentFilter: _filter,
            onFilterChanged: (filter) {
              setState(() {
                _filter = filter;
              });
            },
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (filteredList.isEmpty)
            const EmptyState()
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final todo = filteredList[index];
                return TodoItem(
                  todo: todo,
                  onToggle: () => _toggleTodo(todo),
                  onDelete: () => _deleteTodo(todo),
                  onEdit: () => _editTodo(todo),
                );
              }, childCount: filteredList.length),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
