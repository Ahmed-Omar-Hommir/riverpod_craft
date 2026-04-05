// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'search_movies_provider.dart';

final _$searchMoviesCommand =
    NotifierProvider<
      CommandNotifier<List<Movie>, ({String query})>,
      ArgCommandState<List<Movie>, ({String query})>
    >(() => _$SearchMoviesCommand(), isAutoDispose: true);

class _$SearchMoviesCommand
    extends CommandNotifier<List<Movie>, ({String query})> {
  @override
  Future<List<Movie>> action(Ref ref, ({String query}) arg) =>
      searchMovies(ref, query: arg.query);

  @override
  List<Ref> get refs => [];

  @override
  ActionStrategy get strategy => ActionStrategy.restartable;
}

class $SearchMoviesCommandFacadeRef {
  $SearchMoviesCommandFacadeRef(this._ref);

  final Ref _ref;

  late final _command = _$searchMoviesCommand;

  ArgCommandState<List<Movie>, ({String query})> read() => _ref.read(_command);
  ArgCommandState<List<Movie>, ({String query})> watch() =>
      _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<List<Movie>, ({String query})> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run({required String query}) =>
      _ref.read(_command.notifier).add((query: query));
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<List<Movie>, ({String query})>? previous,
      ArgCommandState<List<Movie>, ({String query})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $SearchMoviesCommandFacadeWidget
    implements
        CommandProviderFacade<List<Movie>, ({String query})>,
        CommandProviderValue<List<Movie>, ({String query})> {
  $SearchMoviesCommandFacadeWidget(this._ref);

  final WidgetRef _ref;

  late final _command = _$searchMoviesCommand;

  @override
  ArgCommandState<List<Movie>, ({String query})> read() => _ref.read(_command);
  @override
  ArgCommandState<List<Movie>, ({String query})> watch() =>
      _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<List<Movie>, ({String query})> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run({required String query}) =>
      _ref.read(_command.notifier).add((query: query));
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(
      ArgCommandState<List<Movie>, ({String query})>? previous,
      ArgCommandState<List<Movie>, ({String query})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<List<Movie>, ({String query})> of(WidgetRef ref) =>
      $SearchMoviesCommandFacadeWidget(ref);
}

extension $SearchMoviesCommandRefEx on Ref {
  $SearchMoviesCommandFacadeRef get searchMoviesCommand =>
      $SearchMoviesCommandFacadeRef(this);
}

extension $SearchMoviesCommandWidgetRefEx on WidgetRef {
  $SearchMoviesCommandFacadeWidget get searchMoviesCommand =>
      $SearchMoviesCommandFacadeWidget(this);
}
