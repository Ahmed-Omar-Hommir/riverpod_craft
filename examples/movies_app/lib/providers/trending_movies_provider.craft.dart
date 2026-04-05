// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'trending_movies_provider.dart';

abstract class _$TrendingMovies extends DataNotifier<List<Movie>, ()> {
  @override
  bool get isFuture => true;

  Future<List<Movie>> create();
  @override
  Future<List<Movie>> buildDataWithFuture() => create();

  Future<double> rateMovie({required int movieId, required double rating});

  late final _$rateMovieCommand =
      NotifierProvider<
        CommandNotifier<double, ({int movieId, double rating})>,
        ArgCommandState<double, ({int movieId, double rating})>
      >(
        () => _$RateMovieCommandTrendingMovies(this as TrendingMovies),
        isAutoDispose: true,
      );

  $RateMovieCommandFacadeTrendingMoviesRef get rateMovieCommand =>
      $RateMovieCommandFacadeTrendingMoviesRef(ref, this as TrendingMovies);
}

final _trendingMoviesProvider =
    NotifierProvider<TrendingMovies, DataState<List<Movie>>>(
      () => TrendingMovies()..arg = (),
      isAutoDispose: true,
    );

class $TrendingMoviesFacadeRef {
  $TrendingMoviesFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _trendingMoviesProvider;

  DataState<List<Movie>> read() => _ref.read(_provider);
  DataState<List<Movie>> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<List<Movie>> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(DataState<List<Movie>>? previous, DataState<List<Movie>> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<List<Movie>>>(_provider, listener, onError: onError);
  }

  $RateMovieCommandFacadeTrendingMoviesRef get rateMovieCommand =>
      $RateMovieCommandFacadeTrendingMoviesRef(
        _ref,
        _ref.read(_provider.notifier),
      );
}

class $TrendingMoviesFacadeWidget
    implements
        DataProviderFacade<List<Movie>>,
        DataProviderValue<List<Movie>, ()> {
  $TrendingMoviesFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _trendingMoviesProvider;

  @override
  DataState<List<Movie>> read() => _ref.read(_provider);
  @override
  DataState<List<Movie>> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<List<Movie>> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  Future<void> reload() => _ref.watch(_provider.notifier).reload();

  @override
  Future<void> silentReload() => _ref.watch(_provider.notifier).silentReload();

  @override
  void listen(
    void Function(DataState<List<Movie>>? previous, DataState<List<Movie>> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<List<Movie>>>(_provider, listener, onError: onError);
  }

  @override
  DataProviderFacade<List<Movie>> of(WidgetRef ref) =>
      $TrendingMoviesFacadeWidget(ref);

  $RateMovieCommandFacadeTrendingMoviesWidget get rateMovieCommand =>
      $RateMovieCommandFacadeTrendingMoviesWidget(
        _ref,
        _ref.read(_provider.notifier),
      );
}

class _$RateMovieCommandTrendingMovies
    extends CommandNotifier<double, ({int movieId, double rating})> {
  _$RateMovieCommandTrendingMovies(this._instance);
  final TrendingMovies _instance;

  @override
  Future<double> action(Ref ref, ({int movieId, double rating}) arg) =>
      _instance.rateMovie(movieId: arg.movieId, rating: arg.rating);

  @override
  List<Ref> get refs => [_instance.ref];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;
}

class $RateMovieCommandFacadeTrendingMoviesRef {
  $RateMovieCommandFacadeTrendingMoviesRef(this._ref, this._instance);
  final TrendingMovies _instance;

  final Ref _ref;

  late final _command = _instance._$rateMovieCommand;

  ArgCommandState<double, ({int movieId, double rating})> read() =>
      _ref.read(_command);
  ArgCommandState<double, ({int movieId, double rating})> watch() =>
      _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<double, ({int movieId, double rating})> state)
    selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run({required int movieId, required double rating}) =>
      _ref.read(_command.notifier).add((movieId: movieId, rating: rating));
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<double, ({int movieId, double rating})>? previous,
      ArgCommandState<double, ({int movieId, double rating})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $RateMovieCommandFacadeTrendingMoviesWidget
    implements
        CommandProviderFacade<double, ({int movieId, double rating})>,
        CommandProviderValue<double, ({int movieId, double rating})> {
  $RateMovieCommandFacadeTrendingMoviesWidget(this._ref, this._instance);
  final TrendingMovies _instance;

  final WidgetRef _ref;

  late final _command = _instance._$rateMovieCommand;

  @override
  ArgCommandState<double, ({int movieId, double rating})> read() =>
      _ref.read(_command);
  @override
  ArgCommandState<double, ({int movieId, double rating})> watch() =>
      _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<double, ({int movieId, double rating})> state)
    selector,
  ) => SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run({required int movieId, required double rating}) =>
      _ref.read(_command.notifier).add((movieId: movieId, rating: rating));
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(
      ArgCommandState<double, ({int movieId, double rating})>? previous,
      ArgCommandState<double, ({int movieId, double rating})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<double, ({int movieId, double rating})> of(
    WidgetRef ref,
  ) => $RateMovieCommandFacadeTrendingMoviesWidget(ref, _instance);
}

extension TrendingMoviesFacadeRefEx on Ref {
  $TrendingMoviesFacadeRef get trendingMoviesProvider =>
      $TrendingMoviesFacadeRef(this);
}

extension TrendingMoviesFacadeWidgetRefEx on WidgetRef {
  $TrendingMoviesFacadeWidget get trendingMoviesProvider =>
      $TrendingMoviesFacadeWidget(this);
}
