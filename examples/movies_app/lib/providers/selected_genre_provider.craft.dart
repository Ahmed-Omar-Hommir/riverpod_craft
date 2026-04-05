part of 'selected_genre_provider.dart';

final _selectedGenreProvider = NotifierProvider<$$SelectedGenre, int?>(
  () => $$SelectedGenre()..arg = (),
  isAutoDispose: true,
);

class $$SelectedGenre extends StateDataNotifier<int?, ()> {
  @override
  int? buildData(() arg) => selectedGenre(ref);
  void updateState(int? value) {
    state = value;
  }
}

class $SelectedGenreFacadeRef {
  $SelectedGenreFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _selectedGenreProvider;

  int? read() => _ref.read(_provider);
  int? watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(R Function(int? state) selector) =>
      SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void setState(int? value) => _ref.read(_provider.notifier).updateState(value);

  void listen(
    void Function(int? previous, int? next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<int?>(_provider, listener, onError: onError);
  }
}

class $SelectedGenreFacadeWidget {
  $SelectedGenreFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _selectedGenreProvider;

  int? read() => _ref.read(_provider);
  int? watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(R Function(int? state) selector) =>
      SelectedWidgetRefFacade(_ref, _provider.select(selector));

  void setState(int? value) => _ref.read(_provider.notifier).updateState(value);

  void listen(
    void Function(int? previous, int? next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<int?>(_provider, listener, onError: onError);
  }
}

extension SelectedGenreFacadeRefEx on Ref {
  $SelectedGenreFacadeRef get selectedGenreProvider =>
      $SelectedGenreFacadeRef(this);
}

extension SelectedGenreFacadeWidgetRefEx on WidgetRef {
  $SelectedGenreFacadeWidget get selectedGenreProvider =>
      $SelectedGenreFacadeWidget(this);
}
