import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/counter_provider.dart';
import 'providers/todo_provider.dart';

void main() {
  runApp(const ProviderScope(child: ExampleApp()));
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod Gen Example',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch counter state using the generated facade
    final count = ref.counterProvider.watch();

    // Watch increment command state
    final incrementState = ref.counterProvider.incrementCommand.watch();

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod Gen Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Counter: $count', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            if (incrementState.isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => ref.counterProvider.decrementCommand.run(),
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrement'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => ref.counterProvider.incrementCommand.run(),
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                ),
              ],
            ),
            const SizedBox(height: 48),
            FilledButton.tonal(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TodoPage()),
              ),
              child: const Text('Go to Todo Example'),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  final _controller = TextEditingController();
  final _todos = <Todo>[];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to addTodo command results
    ref.addTodoCommand.listen((prev, next) {
      next.whenOrNull(
        data: (arg, todo) {
          setState(() => _todos.add(todo));
          _controller.clear();
          ref.addTodoCommand.reset();
        },
      );
    });

    // Listen to toggleTodo command results
    ref.toggleTodoCommand.listen((prev, next) {
      next.whenOrNull(
        data: (arg, updatedTodo) {
          setState(() {
            final index = _todos.indexWhere((t) => t.id == updatedTodo.id);
            if (index != -1) _todos[index] = updatedTodo;
          });
          ref.toggleTodoCommand.reset();
        },
      );
    });

    final addState = ref.addTodoCommand.watch();

    return Scaffold(
      appBar: AppBar(title: const Text('Todo Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter todo title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (addState.isLoading)
                  const CircularProgressIndicator()
                else
                  IconButton.filled(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        ref.addTodoCommand.run(title: _controller.text);
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return ListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration:
                          todo.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: todo.completed,
                    onChanged: (_) {
                      ref.toggleTodoCommand.run(todo: todo);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
