import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

final loads = <Completer<int>>[];

class Src extends DataNotifier<int, Object, ()> {
  @override
  bool get isFuture => true;

  @override
  Future<int> buildDataWithFuture() {
    final c = Completer<int>();
    loads.add(c);
    return c.future;
  }
}

final srcProvider = NotifierProvider<Src, DataState<int, Object>>(
  () => Src()..arg = (),
);

final pagedLoads = <Completer<PaginatedResponse<int, int>>>[];

class Pg extends PagedDataNotifier<int, Object, (), int> {
  @override
  final int firstPageKey = 1;

  @override
  Future<PaginatedResponse<int, int>> buildPagedData(int page) {
    final c = Completer<PaginatedResponse<int, int>>();
    pagedLoads.add(c);
    return c.future;
  }
}

final pagedProvider =
    NotifierProvider<Pg, PagedDataState<int, Object, int>>(() => Pg()..arg = ());

int initCount = 0;
Notifier? lastNotifier;
int loadsAtInit = -1;
int pagedLoadsAtInit = -1;

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  setUp(() {
    loads.clear();
    pagedLoads.clear();
    initCount = 0;
    lastNotifier = null;
    loadsAtInit = -1;
    pagedLoadsAtInit = -1;
    RiverpodCraft.providerInit = null;
  });
  tearDown(() => RiverpodCraft.providerInit = null);

  test('runs once per data notifier, before the fetch, not on reload', () async {
    RiverpodCraft.providerInit = (ref, notifier, arg) async {
      initCount++;
      lastNotifier = notifier;
      loadsAtInit = loads.length;
    };
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(srcProvider);
    await flush();

    expect(initCount, 1);
    expect(lastNotifier, isA<DataNotifier>());
    expect(loadsAtInit, 0, reason: 'init runs before the first fetch');
    expect(loads.length, 1);

    loads[0].complete(7);
    await flush();

    // reload must NOT re-run init (no listener/registration storm)
    container.read(srcProvider.notifier).reload();
    await flush();
    expect(initCount, 1);
    expect(loads.length, 2);
  });

  test('runs once per paged notifier, before page 1, not on next page', () async {
    RiverpodCraft.providerInit = (ref, notifier, arg) async {
      initCount++;
      lastNotifier = notifier;
      pagedLoadsAtInit = pagedLoads.length;
    };
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(pagedProvider);
    await flush();

    expect(initCount, 1);
    expect(lastNotifier, isA<PagedDataNotifier>());
    expect(pagedLoadsAtInit, 0, reason: 'init runs before page 1');
    expect(pagedLoads.length, 1);

    pagedLoads[0].complete(
      const PaginatedResponse(results: [1], nextPageKey: 2),
    );
    await flush();

    container.read(pagedProvider.notifier).fetchNextPage();
    await flush();
    expect(initCount, 1);
    expect(pagedLoads.length, 2);
  });

  test('no hook registered → no-op, fetch still runs', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(srcProvider);
    await flush();
    expect(loads.length, 1);
  });
}
