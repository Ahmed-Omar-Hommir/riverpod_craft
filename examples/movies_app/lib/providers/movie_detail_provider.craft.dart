// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'movie_detail_provider.dart';

final _movieDetailProvider =
    NotifierProvider.family<
      $$MovieDetail,
      DataState<Movie, Object>,
      ({int id})
    >((({int id}) arg) => $$MovieDetail()..arg = arg, isAutoDispose: true);

class $$MovieDetail extends DataNotifier<Movie, Object, ({int id})> {
  @override
  bool get isFuture => true;

  @override
  Future<Movie> buildDataWithFuture() => movieDetail(ref, id: arg.id);
}

class $MovieDetailFacadeRef {
  $MovieDetailFacadeRef(this._ref, this._arg);
  final Ref _ref;
  final ({int id}) _arg;

  late final _provider = _movieDetailProvider(_arg);

  DataState<Movie, Object> read() => _ref.read(_provider);
  DataState<Movie, Object> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<Movie, Object> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  Future<Movie> future({bool watch = false, bool forceRefetch = false}) {
    if (!watch) {
      return _ref.read(_provider.notifier).future(forceRefetch: forceRefetch);
    }
    return DataWatchHandle<Movie, Object>(
      read: () => _ref.read(_provider),
      reload: () => _ref.read(_provider.notifier).reload(),
      listen: (listener) => _ref.listen(_provider, listener),
      invalidateSelf: () => _ref.invalidateSelf(),
    ).future(forceRefetch: forceRefetch);
  }

  void listen(
    void Function(
      DataState<Movie, Object>? previous,
      DataState<Movie, Object> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Movie, Object>>(
      _provider,
      listener,
      onError: onError,
    );
  }
}

class $MovieDetailFacadeWidget
    implements
        DataProviderFacade<Movie, Object>,
        DataProviderValue<Movie, Object> {
  $MovieDetailFacadeWidget(this._ref, this._arg);
  final WidgetRef _ref;
  final ({int id}) _arg;

  late final _provider = _movieDetailProvider(_arg);

  @override
  DataState<Movie, Object> read() => _ref.read(_provider);
  @override
  DataState<Movie, Object> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<Movie, Object> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  Future<void> reload() => _ref.watch(_provider.notifier).reload();

  @override
  Future<void> silentReload() => _ref.watch(_provider.notifier).silentReload();
  Future<Movie> future({bool forceRefetch = false}) =>
      _ref.read(_provider.notifier).future(forceRefetch: forceRefetch);

  @override
  void listen(
    void Function(
      DataState<Movie, Object>? previous,
      DataState<Movie, Object> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Movie, Object>>(
      _provider,
      listener,
      onError: onError,
    );
  }

  @override
  DataProviderFacade<Movie, Object> of(WidgetRef ref) =>
      $MovieDetailFacadeWidget(ref, _arg);
}

class $MovieDetailFacadeRefCallable {
  $MovieDetailFacadeRefCallable(this._ref);
  final Ref _ref;

  $MovieDetailFacadeRef call({required int id}) =>
      $MovieDetailFacadeRef(_ref, (id: id));

  void invalidateFamily() => _ref.invalidate(_movieDetailProvider);
}

class $MovieDetailFacadeWidgetCallable {
  $MovieDetailFacadeWidgetCallable(this._ref);
  final WidgetRef _ref;

  $MovieDetailFacadeWidget call({required int id}) =>
      $MovieDetailFacadeWidget(_ref, (id: id));

  void invalidateFamily() => _ref.invalidate(_movieDetailProvider);
}

extension MovieDetailFacadeRefEx on Ref {
  $MovieDetailFacadeRefCallable get movieDetailProvider =>
      $MovieDetailFacadeRefCallable(this);
}

extension MovieDetailFacadeWidgetRefEx on WidgetRef {
  $MovieDetailFacadeWidgetCallable get movieDetailProvider =>
      $MovieDetailFacadeWidgetCallable(this);
}
