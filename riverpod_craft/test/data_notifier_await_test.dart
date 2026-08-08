import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

/// Controllable async source: each load pulls the next queued completer, so the
/// test drives the Loading -> Data / Failure transitions by hand.
final List<Completer<int>> loads = [];

class SourceNotifier extends DataNotifier<int, Object, ()> {
  @override
  bool get isFuture => true;

  @override
  Future<int> buildDataWithFuture() {
    final completer = Completer<int>();
    loads.add(completer);
    return completer.future;
  }

  // Directly emit a new data value (Data -> Data', no loading transition).
  void emit(int value) => state = DataState.data(value);
}

/// Dependent that awaits a *selected* slice (the tens digit) of the source.
int selectDependentBuilds = 0;

class SelectDependentNotifier extends DataNotifier<int, Object, ()> {
  @override
  bool get isFuture => true;

  @override
  Future<int> buildDataWithFuture() {
    selectDependentBuilds++;
    final handle = DataWatchHandle<int, Object>(
      read: () => ref.read(sourceProvider),
      reload: () => ref.read(sourceProvider.notifier).reload(),
      listen: (listener) => ref.listen(sourceProvider, listener),
      invalidateSelf: () => ref.invalidateSelf(),
    );
    return handle.future<int>((data) => data ~/ 10);
  }
}

final selectDependentProvider =
    NotifierProvider<SelectDependentNotifier, DataState<int, Object>>(
      () => SelectDependentNotifier()..arg = (),
    );

final sourceProvider = NotifierProvider<SourceNotifier, DataState<int, Object>>(
  () => SourceNotifier()..arg = (),
);

/// Dependent that awaits the source via `.watch.future` — hand-wired
/// [DataWatchHandle] exactly as the generator emits it.
int dependentBuilds = 0;
bool watchForceRefetch = false;

class DependentNotifier extends DataNotifier<int, Object, ()> {
  @override
  bool get isFuture => true;

  @override
  Future<int> buildDataWithFuture() async {
    dependentBuilds++;
    final handle = DataWatchHandle<int, Object>(
      read: () => ref.read(sourceProvider),
      reload: () => ref.read(sourceProvider.notifier).reload(),
      listen: (listener) => ref.listen(sourceProvider, listener),
      invalidateSelf: () => ref.invalidateSelf(),
    );
    final value = await handle.future<int>(
      (data) => data,
      forceRefetch: watchForceRefetch,
    );
    return value * 10;
  }
}

final dependentProvider =
    NotifierProvider<DependentNotifier, DataState<int, Object>>(
      () => DependentNotifier()..arg = (),
    );

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  setUp(() {
    loads.clear();
    dependentBuilds = 0;
    selectDependentBuilds = 0;
    watchForceRefetch = false;
  });

  group('DataNotifier.future()', () {
    test('returns cached data without a new load', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(sourceProvider);
      await flush();
      loads[0].complete(1);
      await flush();

      final value = await container.read(sourceProvider.notifier).future();
      expect(value, 1);
      expect(loads.length, 1);
    });

    test('awaits an in-flight load', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(sourceProvider);
      await flush();

      final future = container.read(sourceProvider.notifier).future();
      loads[0].complete(7);
      expect(await future, 7);
    });

    test('forceRefetch reloads and returns the fresh value', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(sourceProvider);
      await flush();
      loads[0].complete(1);
      await flush();

      final future = container
          .read(sourceProvider.notifier)
          .future(forceRefetch: true);
      await flush();
      expect(loads.length, 2);
      loads[1].complete(2);
      expect(await future, 2);
    });

    test('retries when the state is an error', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(sourceProvider);
      await flush();
      loads[0].completeError(Exception('boom'));
      await flush();
      expect(container.read(sourceProvider).isError, isTrue);

      final future = container.read(sourceProvider.notifier).future();
      await flush();
      expect(loads.length, 2);
      loads[1].complete(9);
      expect(await future, 9);
    });

    test('throws the error when the fetch fails', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(sourceProvider);
      await flush();

      final future = container.read(sourceProvider.notifier).future();
      loads[0].completeError(Exception('nope'));
      await expectLater(future, throwsA(isA<Exception>()));
    });
  });

  group('.watch.future selective rebuild', () {
    test('no rebuild on Loading->Data, rebuild on Done->Loading', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(dependentProvider, (_, _) {});
      await flush();

      // Built once, awaiting the source's first load.
      expect(dependentBuilds, 1);

      loads[0].complete(1);
      await flush();
      // Resolved with 10 — NO rebuild on the awaited Loading->Data.
      expect(dependentBuilds, 1);
      expect(
        container.read(dependentProvider),
        const DataSuccess<int, Object>(10),
      );

      // Reloading the source (Data->Loading) rebuilds the dependent once...
      container.invalidate(sourceProvider);
      await flush();
      expect(dependentBuilds, 2);

      // ...and the subsequent Loading->Data does NOT rebuild again.
      loads[1].complete(2);
      await flush();
      expect(dependentBuilds, 2);
      expect(
        container.read(dependentProvider),
        const DataSuccess<int, Object>(20),
      );
    });

    test('forceRefetch reloads the source without self-invalidating', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Prime the source with cached data.
      container.read(sourceProvider);
      await flush();
      loads[0].complete(1);
      await flush();

      // The dependent force-refetches through watch.future.
      watchForceRefetch = true;
      container.listen(dependentProvider, (_, _) {});
      await flush();
      // Built once; forced a fresh source load despite the cached value...
      expect(dependentBuilds, 1);
      expect(loads.length, 2);

      loads[1].complete(2);
      await flush();
      // ...and did NOT rebuild from its own forced Done->Loading.
      expect(dependentBuilds, 1);
      expect(
        container.read(dependentProvider),
        const DataSuccess<int, Object>(20),
      );
    });

    test('survives the source being invalidated twice mid-load', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(dependentProvider, (_, _) {});
      await flush();
      loads[0].complete(1);
      await flush();
      expect(
        container.read(dependentProvider),
        const DataSuccess<int, Object>(10),
      );

      // Invalidate the source twice — the first disposes the notifier the
      // dependent is awaiting; the second (Loading->Loading) does not rebuild
      // the dependent. It must still resolve off the live notifier.
      container.invalidate(sourceProvider);
      container.invalidate(sourceProvider);
      await flush();

      for (final load in loads) {
        if (!load.isCompleted) load.complete(5);
      }
      await flush();
      expect(
        container.read(dependentProvider),
        const DataSuccess<int, Object>(50),
      );
    });

    test('select() rebuilds only when the selected value changes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(selectDependentProvider, (_, _) {});
      await flush();
      loads[0].complete(20);
      await flush();
      expect(selectDependentBuilds, 1);
      expect(
        container.read(selectDependentProvider),
        const DataSuccess<int, Object>(2),
      );

      // 20 -> 25: same tens digit → no rebuild.
      container.read(sourceProvider.notifier).emit(25);
      await flush();
      expect(selectDependentBuilds, 1);

      // 25 -> 30: tens digit changed → rebuild.
      container.read(sourceProvider.notifier).emit(30);
      await flush();
      expect(selectDependentBuilds, 2);
      expect(
        container.read(selectDependentProvider),
        const DataSuccess<int, Object>(3),
      );
    });
  });
}
