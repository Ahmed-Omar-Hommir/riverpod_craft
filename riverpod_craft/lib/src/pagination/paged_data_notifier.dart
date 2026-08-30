import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod/riverpod.dart';

import '../error_mapper.dart';
import '../provider_init.dart';
import 'paged_data_state.dart';
import 'paginated_response.dart';

abstract class PagedDataNotifier<T, F, Arg extends Record, PageKey>
    extends Notifier<PagedDataState<T, F, PageKey>>
    with ErrorMapper<F> {
  late final Arg arg;

  Future<PaginatedResponse<T, PageKey>> buildPagedData(PageKey pageKey);

  bool _pending = false;

  @protected
  abstract final PageKey firstPageKey;

  PageKey? _nextPageKey;

  /// Runs once per notifier instance, before the first page fetch. Defaults to
  /// the globally-registered [RiverpodCraft.providerInit]; the generator
  /// overrides it to a no-op for providers annotated `@noInit`.
  @protected
  Future<void> init() async {
    final hook = RiverpodCraft.providerInit;
    if (hook != null) await hook(ref, this, arg);
  }

  @override
  PagedDataState<T, F, PageKey> build() {
    _pending = false;
    _nextPageKey = null;

    Future.microtask(() async {
      await init();
      if (!ref.mounted) return;
      await fetchNextPage();
    });
    return PagedDataState<T, F, PageKey>(PagingState());
  }

  Future<void> fetchNextPage() async {
    if (_pending) return;
    final s = state.pagingState;
    if (s.isLoading) return;
    if (!s.hasNextPage && s.pages != null && s.pages!.isNotEmpty) return;

    _pending = true;
    state = PagedDataState<T, F, PageKey>(
      s.copyWith(isLoading: true, error: null),
    );

    final isFirstPage = s.pages == null;

    final pageKey = isFirstPage ? firstPageKey : _nextPageKey;

    try {
      final response = await buildPagedData(pageKey as PageKey);
      if (!ref.mounted) return;

      _nextPageKey = response.nextPageKey;

      state = PagedDataState<T, F, PageKey>(
        s.copyWith(
          pages: [...?s.pages, response.results],
          keys: [...?s.keys, pageKey],
          hasNextPage: response.nextPageKey != null,
          isLoading: false,
        ),
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = PagedDataState<T, F, PageKey>(
        s.copyWith(error: mapError(error), isLoading: false),
      );
    } finally {
      _pending = false;
    }
  }

  Future<void> reload() async {
    _pending = false;
    _nextPageKey = null;
    state = PagedDataState<T, F, PageKey>(PagingState());
    await fetchNextPage();
  }

  /// Re-attempts the page fetch that just failed — the first page or a next
  /// page — without discarding already-loaded pages. No-op unless the list is
  /// in an error state (use [reload] to restart from the first page).
  ///
  /// A failed fetch never advances `_nextPageKey`/`pages`, so re-running
  /// [fetchNextPage] targets the same page that failed.
  Future<void> retry() async {
    if (!state.hasError) return;
    await fetchNextPage();
  }
}
