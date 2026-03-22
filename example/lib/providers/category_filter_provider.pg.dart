part of 'category_filter_provider.dart';

final _categoryFilterProvider =
    NotifierProvider.family<$$CategoryFilter, NoteCategory, ({int id})>(
      (({int id}) arg) => $$CategoryFilter()..arg = arg,
      isAutoDispose: true,
    );

class $$CategoryFilter extends StateDataNotifier<NoteCategory, ({int id})> {
  @override
  NoteCategory buildData(({int id}) arg) => categoryFilter(ref, id: arg.id);
}

class $CategoryFilterFacadeRef {
  $CategoryFilterFacadeRef(this._ref, this._arg);
  final Ref _ref;
  final ({int id}) _arg;

  late final _provider = _categoryFilterProvider(_arg);

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
  $CategoryFilterFacadeWidget(this._ref, this._arg);
  final WidgetRef _ref;
  final ({int id}) _arg;

  late final _provider = _categoryFilterProvider(_arg);

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

class $CategoryFilterFacadeRefCallable {
  $CategoryFilterFacadeRefCallable(this._ref);
  final Ref _ref;

  $CategoryFilterFacadeRef call({required int id}) =>
      $CategoryFilterFacadeRef(_ref, (id: id));

  void invalidateFamily() => _ref.invalidate(_categoryFilterProvider);
}

class $CategoryFilterFacadeWidgetCallable {
  $CategoryFilterFacadeWidgetCallable(this._ref);
  final WidgetRef _ref;

  $CategoryFilterFacadeWidget call({required int id}) =>
      $CategoryFilterFacadeWidget(_ref, (id: id));

  void invalidateFamily() => _ref.invalidate(_categoryFilterProvider);
}

extension CategoryFilterFacadeRefEx on Ref {
  $CategoryFilterFacadeRefCallable get categoryFilterProvider =>
      $CategoryFilterFacadeRefCallable(this);
}

extension CategoryFilterFacadeWidgetRefEx on WidgetRef {
  $CategoryFilterFacadeWidgetCallable get categoryFilterProvider =>
      $CategoryFilterFacadeWidgetCallable(this);
}
