import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

import '../providers/counter_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _SimpleCounterCard(),
            SizedBox(height: 16),
            _BoundedCounterCard(),
          ],
        ),
      ),
    );
  }
}

// ── Simple Counter (@settable) ────────────────────────────────────────────────

class _SimpleCounterCard extends ConsumerWidget {
  const _SimpleCounterCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.counterProvider.watch();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Simple Counter', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '@settable — direct setState, no custom logic',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$count',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: () => ref.counterProvider.setState(count - 1),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 24),
                FilledButton.tonal(
                  onPressed: () => ref.counterProvider.setState(count + 1),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.counterProvider.setState(0),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bounded Counter (class-based) ─────────────────────────────────────────────

class _BoundedCounterCard extends ConsumerWidget {
  const _BoundedCounterCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.boundedCounterProvider.watch();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final atCeiling = count == 0; // decrement stops here

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Bounded Counter', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'class-based — custom methods, capped at 0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$count',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: atCeiling ? cs.onSurfaceVariant : cs.error,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: atCeiling
                      ? null
                      : () => ref.boundedCounterProvider.decrement(),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 24),
                FilledButton.tonal(
                  onPressed: () => ref.boundedCounterProvider.increment(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: atCeiling
                  ? null
                  : () => ref.boundedCounterProvider.reset(),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
