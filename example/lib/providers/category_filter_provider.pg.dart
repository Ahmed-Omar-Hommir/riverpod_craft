part of 'category_filter_provider.dart';

abstract class _$CategoryFilter extends StateDataNotifier<NoteCategory, ()> {
  NoteCategory create();
  @override
  NoteCategory buildData(() arg) => create();
}

final _categoryFilterProvider = NotifierProvider(
  () => CategoryFilter()..arg = (),
  isAutoDispose: true,
);

class $CategoryFilterFacadeRef {
  $CategoryFilterFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _categoryFilterProvider;

  NoteCategory read() => _ref.read(_provider);
  NoteCategory watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(R Function(NoteCategory state) selector) =>
      SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void setState(NoteCategory value) =>
      _ref.read(_provider.notifier).updateState(value);

  void listen(
    void Function(NoteCategory? previous, NoteCategory next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<NoteCategory>(_provider, listener, onError: onError);
  }
}

class $CategoryFilterFacadeWidget {
  $CategoryFilterFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _categoryFilterProvider;

  NoteCategory read() => _ref.read(_provider);
  NoteCategory watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(NoteCategory state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));

  void setState(NoteCategory value) =>
      _ref.read(_provider.notifier).updateState(value);

  void listen(
    void Function(NoteCategory? previous, NoteCategory next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<NoteCategory>(_provider, listener, onError: onError);
  }
}

extension CategoryFilterFacadeRefEx on Ref {
  $CategoryFilterFacadeRef get categoryFilterProvider =>
      $CategoryFilterFacadeRef(this);
}

extension CategoryFilterFacadeWidgetRefEx on WidgetRef {
  $CategoryFilterFacadeWidget get categoryFilterProvider =>
      $CategoryFilterFacadeWidget(this);
}
