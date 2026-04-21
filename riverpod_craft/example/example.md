## Counter Example

A simple counter with `@provider` and `@settable`:

```dart
import 'package:riverpod_craft/riverpod_craft.dart';

part 'counter_provider.craft.dart';

// Generates a provider with setState() automatically.
@provider
@settable
int counter(Ref ref) => 0;
```

Use in a widget — access via the generated extension on `WidgetRef`:

```dart
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.counterProvider.watch();

    return Scaffold(
      body: Center(child: Text('$count')),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => ref.counterProvider.setState(count + 1),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => ref.counterProvider.setState(count - 1),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
```

See the full [examples](https://github.com/Ahmed-Omar-Hommir/riverpod_craft/tree/master/examples) directory for more: counter, notes, movies_app, command_strategies, quote, and custom_dropdown.
