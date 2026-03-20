part of 'search_query_provider.dart';

final _searchQueryProvider = NotifierProvider(
  () => $$SearchQuery()..arg = (),
  isAutoDispose: true,
);

class $$SearchQuery extends StateDataNotifier<String, ()> {
  @override
  String buildData(() arg) => searchQuery(ref);
}

class $SearchQueryFacadeRef {
  $SearchQueryFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _searchQueryProvider;

  String read() => _ref.read(_provider);
  String watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(R Function(String state) selector) =>
      SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(String? previous, String next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<String>(_provider, listener, onError: onError);
  }
}

class $SearchQueryFacadeWidget {
  $SearchQueryFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _searchQueryProvider;

  String read() => _ref.read(_provider);
  String watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(R Function(String state) selector) =>
      SelectedWidgetRefFacade(_ref, _provider.select(selector));

  void setState(String value) =>
      _ref.read(_provider.notifier).updateState(value);

  void listen(
    void Function(String? previous, String next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<String>(_provider, listener, onError: onError);
  }
}

extension SearchQueryFacadeRefEx on Ref {
  $SearchQueryFacadeRef get searchQueryProvider => $SearchQueryFacadeRef(this);
}

extension SearchQueryFacadeWidgetRefEx on WidgetRef {
  $SearchQueryFacadeWidget get searchQueryProvider =>
      $SearchQueryFacadeWidget(this);
}
