import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'paged_data_state.dart';

/// Interface for interacting with a paginated provider's state.
///
/// Generated Widget facades implement this.
abstract class PagedDataProviderFacade<T> {
  PagedDataState<T> read();
  PagedDataState<T> watch();
  void fetchNextPage();
  void invalidate();

  void listen(
    void Function(PagedDataState<T>? previous, PagedDataState<T> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  });
}

/// Interface for creating a [PagedDataProviderFacade] from a [WidgetRef].
///
/// The generated Widget facade implements both [PagedDataProviderFacade]
/// and [PagedProviderValue]. Pass this to [CraftPagedListView]:
///
/// ```dart
/// CraftPagedListView<Note>(
///   provider: ref.notesProvider(category: 'work'),
///   itemBuilder: (context, note, index) => ListTile(title: Text(note.title)),
/// )
/// ```
abstract class PagedProviderValue<T> {
  PagedDataProviderFacade<T> of(WidgetRef ref);
}
