---
sidebar_position: 2
---

# Counter

The simplest example — two counters showing the two ways to define providers.

**What you'll learn:**
- `@provider` on a function for simple state
- `@settable` to update state directly
- `@provider` on a class for custom methods

[Source code](https://github.com/Ahmed-Omar-Hommir/riverpod_craft/tree/master/examples/counter)

---

## Providers

### Simple counter — `@settable`

When all you need is get/set with no logic, use `@settable`:

```dart
@provider
@settable
int counter(Ref ref) => 0;
```

This generates `ref.counterProvider.watch()` to read the value and `ref.counterProvider.setState(newValue)` to update it.

### Bounded counter — class-based

When you need custom methods or validation, use a class:

```dart
@provider
class BoundedCounter extends _$BoundedCounter {
  @override
  int create() => 0;

  void decrement() {
    if (state == 0) return;
    state--;
  }

  void increment() {
    if (state < 0) return;
    state++;
  }

  void reset() {
    state = 0;
  }
}
```

This generates `ref.boundedCounterProvider` with `.watch()`, `.increment()`, `.decrement()`, and `.reset()`.

---

## Usage

```dart
class _SimpleCounterCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.counterProvider.watch();

    return Column(
      children: [
        Text('$count'),
        Row(
          children: [
            FilledButton.tonal(
              onPressed: () => ref.counterProvider.setState(count - 1),
              child: const Icon(Icons.remove),
            ),
            FilledButton.tonal(
              onPressed: () => ref.counterProvider.setState(count + 1),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        TextButton(
          onPressed: () => ref.counterProvider.setState(0),
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
```

```dart
class _BoundedCounterCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.boundedCounterProvider.watch();

    return Column(
      children: [
        Text('$count'),
        Row(
          children: [
            FilledButton.tonal(
              onPressed: () => ref.boundedCounterProvider.decrement(),
              child: const Icon(Icons.remove),
            ),
            FilledButton.tonal(
              onPressed: () => ref.boundedCounterProvider.increment(),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        TextButton(
          onPressed: () => ref.boundedCounterProvider.reset(),
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
```
