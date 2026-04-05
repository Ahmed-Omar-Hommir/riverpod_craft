// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'now_playing_provider.dart';

final _nowPlayingProvider =
    NotifierProvider<$$NowPlaying, DataState<List<Movie>>>(
      () => $$NowPlaying()..arg = (),
      isAutoDispose: true,
    );

class $$NowPlaying extends DataNotifier<List<Movie>, ()> {
  @override
  bool get isFuture => false;

  @override
  Stream<List<Movie>> buildDataWithStream() => nowPlaying(ref);
}

class $NowPlayingFacadeRef {
  $NowPlayingFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _nowPlayingProvider;

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
}

class $NowPlayingFacadeWidget
    implements
        DataProviderFacade<List<Movie>>,
        DataProviderValue<List<Movie>, ()> {
  $NowPlayingFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _nowPlayingProvider;

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
      $NowPlayingFacadeWidget(ref);
}

extension NowPlayingFacadeRefEx on Ref {
  $NowPlayingFacadeRef get nowPlayingProvider => $NowPlayingFacadeRef(this);
}

extension NowPlayingFacadeWidgetRefEx on WidgetRef {
  $NowPlayingFacadeWidget get nowPlayingProvider =>
      $NowPlayingFacadeWidget(this);
}
