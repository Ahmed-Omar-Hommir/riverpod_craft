// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'popular_movies_provider.dart';

typedef Paged<T> = Future<PaginatedResponse<T>>;

abstract class _$PopularMovies
    extends PagedDataNotifier<Movie, ({int? genreId})> {
  Paged<Movie> create(int page, {required int? genreId});
  @override
  Future<PaginatedResponse<Movie>> buildPagedData(int page) =>
      create(page, genreId: arg.genreId);
}

final _popularMoviesProvider =
    NotifierProvider.family<
      PopularMovies,
      PagedDataState<Movie>,
      ({int? genreId})
    >(
      (({int? genreId}) arg) => PopularMovies()..arg = arg,
      isAutoDispose: true,
    );

class $PopularMoviesFacadeRef {
  $PopularMoviesFacadeRef(this._ref, this._arg);
  final Ref _ref;
  final ({int? genreId}) _arg;

  late final _provider = _popularMoviesProvider(_arg);

  PagedDataState<Movie> read() => _ref.read(_provider);
  PagedDataState<Movie> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(PagedDataState<Movie> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void fetchNextPage() => _ref.read(_provider.notifier).fetchNextPage();
  Future<void> reload() => _ref.read(_provider.notifier).reload();

  void listen(
    void Function(PagedDataState<Movie>? previous, PagedDataState<Movie> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<PagedDataState<Movie>>(_provider, listener, onError: onError);
  }
}

class $PopularMoviesFacadeWidget
    implements PagedDataProviderFacade<Movie>, PagedProviderValue<Movie> {
  $PopularMoviesFacadeWidget(this._ref, this._arg);
  final WidgetRef _ref;
  final ({int? genreId}) _arg;

  late final _provider = _popularMoviesProvider(_arg);

  @override
  PagedDataState<Movie> read() => _ref.read(_provider);
  @override
  PagedDataState<Movie> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(PagedDataState<Movie> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  void fetchNextPage() => _ref.read(_provider.notifier).fetchNextPage();

  Future<void> reload() => _ref.read(_provider.notifier).reload();

  void listen(
    void Function(PagedDataState<Movie>? previous, PagedDataState<Movie> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<PagedDataState<Movie>>(_provider, listener, onError: onError);
  }

  @override
  PagedDataProviderFacade<Movie> of(WidgetRef ref) =>
      $PopularMoviesFacadeWidget(ref, _arg);
}

class $PopularMoviesFacadeRefCallable {
  $PopularMoviesFacadeRefCallable(this._ref);
  final Ref _ref;

  $PopularMoviesFacadeRef call({required int? genreId}) =>
      $PopularMoviesFacadeRef(_ref, (genreId: genreId));

  void invalidateFamily() => _ref.invalidate(_popularMoviesProvider);
}

class $PopularMoviesFacadeWidgetCallable {
  $PopularMoviesFacadeWidgetCallable(this._ref);
  final WidgetRef _ref;

  $PopularMoviesFacadeWidget call({required int? genreId}) =>
      $PopularMoviesFacadeWidget(_ref, (genreId: genreId));

  void invalidateFamily() => _ref.invalidate(_popularMoviesProvider);
}

extension PopularMoviesFacadeRefEx on Ref {
  $PopularMoviesFacadeRefCallable get popularMoviesProvider =>
      $PopularMoviesFacadeRefCallable(this);
}

extension PopularMoviesFacadeWidgetRefEx on WidgetRef {
  $PopularMoviesFacadeWidgetCallable get popularMoviesProvider =>
      $PopularMoviesFacadeWidgetCallable(this);
}
