import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_gen/riverpod_gen.dart';

part 'todo_provider.pg.dart';

/// A simple Todo model
class Todo {
  const Todo({required this.id, required this.title, this.completed = false});
  final int id;
  final String title;
  final bool completed;

  Todo copyWith({int? id, String? title, bool? completed}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}

/// Top-level command to add a todo.
///
/// Demonstrates @command with arguments and @droppable strategy.
@command
@droppable
Future<Todo> addTodo(Ref ref, {required String title}) async {
  // Simulate API call
  await Future.delayed(const Duration(milliseconds: 500));
  final id = DateTime.now().millisecondsSinceEpoch;
  return Todo(id: id, title: title);
}

/// Top-level command to toggle a todo's completion status.
@command
@droppable
Future<Todo> toggleTodo(Ref ref, {required Todo todo}) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return todo.copyWith(completed: !todo.completed);
}
