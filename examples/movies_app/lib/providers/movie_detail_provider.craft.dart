// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'movie_detail_provider.dart';

final _movieDetailProvider =
    NotifierProvider.family<$$MovieDetail, DataState<Movie>, ({int id})>(
      (({int id}) arg) => $$MovieDetail()..arg = arg,
      isAutoDispose: true,
    );

class $$MovieDetail extends DataNotifier<Movie, ({int id})> {
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

  DataState<Movie> read() => _ref.read(_provider);
  DataState<Movie> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(R Function(DataState<Movie> state) selector) =>
      SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(DataState<Movie>? previous, DataState<Movie> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Movie>>(_provider, listener, onError: onError);
  }
}

class $MovieDetailFacadeWidget
    implements DataProviderFacade<Movie>, DataProviderValue<Movie> {
  $MovieDetailFacadeWidget(this._ref, this._arg);
  final WidgetRef _ref;
  final ({int id}) _arg;

  late final _provider = _movieDetailProvider(_arg);

  @override
  DataState<Movie> read() => _ref.read(_provider);
  @override
  DataState<Movie> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<Movie> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  Future<void> reload() => _ref.watch(_provider.notifier).reload();

  @override
  Future<void> silentReload() => _ref.watch(_provider.notifier).silentReload();

  @override
  void listen(
    void Function(DataState<Movie>? previous, DataState<Movie> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Movie>>(_provider, listener, onError: onError);
  }

  @override
  DataProviderFacade<Movie> of(WidgetRef ref) =>
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
