// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'popular_movies_provider.dart';

typedef Paged<T> = Future<MoviesPage<T>>;

PaginatedResponse<T, int> pagedMapper<T>(MoviesPage<T> data) {
  return PaginatedResponse(
    results: data.results,
    nextPageKey: data.page < data.totalPages ? data.page + 1 : null,
  );
}

abstract class _$PopularMovies
    extends PagedDataNotifier<Movie, Object, ({int? genreId}), int> {
  @override
  final int firstPageKey = 1;

  Paged<Movie> create(int page, {required int? genreId});
  @override
  Future<PaginatedResponse<Movie, int>> buildPagedData(int page) async =>
      pagedMapper(await create(page, genreId: arg.genreId));
}

final _popularMoviesProvider =
    NotifierProvider.family<
      PopularMovies,
      PagedDataState<Movie, Object, int>,
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

  PagedDataState<Movie, Object, int> read() => _ref.read(_provider);
  PagedDataState<Movie, Object, int> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(PagedDataState<Movie, Object, int> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void fetchNextPage() => _ref.read(_provider.notifier).fetchNextPage();
  Future<void> reload() => _ref.read(_provider.notifier).reload();
  Future<void> retry() => _ref.read(_provider.notifier).retry();

  void listen(
    void Function(
      PagedDataState<Movie, Object, int>? previous,
      PagedDataState<Movie, Object, int> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<PagedDataState<Movie, Object, int>>(
      _provider,
      listener,
      onError: onError,
    );
  }
}

class $PopularMoviesFacadeWidget
    implements
        PagedProviderFacade<Movie, Object, int>,
        PagedProviderValue<Movie, Object, int> {
  $PopularMoviesFacadeWidget(this._ref, this._arg);
  final WidgetRef _ref;
  final ({int? genreId}) _arg;

  late final _provider = _popularMoviesProvider(_arg);

  PagedDataState<Movie, Object, int> read() => _ref.read(_provider);
  PagedDataState<Movie, Object, int> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(PagedDataState<Movie, Object, int> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  void fetchNextPage() => _ref.read(_provider.notifier).fetchNextPage();

  Future<void> reload() => _ref.read(_provider.notifier).reload();

  Future<void> retry() => _ref.read(_provider.notifier).retry();

  void listen(
    void Function(
      PagedDataState<Movie, Object, int>? previous,
      PagedDataState<Movie, Object, int> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<PagedDataState<Movie, Object, int>>(
      _provider,
      listener,
      onError: onError,
    );
  }

  @override
  PagedProviderFacade<Movie, Object, int> of(WidgetRef ref) =>
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
