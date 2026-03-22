part of 'note_detail_provider.dart';

final _noteDetailProvider = NotifierProvider.family(
  (({String id}) arg) => $$NoteDetail()..arg = arg,
  isAutoDispose: true,
);

class $$NoteDetail extends DataNotifier<Note, ({String id})> {
  @override
  bool get isFuture => true;

  @override
  Future<Note> buildDataWithFuture() => noteDetail(ref, id: arg.id);
}

class $NoteDetailFacadeRef {
  $NoteDetailFacadeRef(this._ref, this._arg);
  final Ref _ref;
  final ({String id}) _arg;

  late final _provider = _noteDetailProvider(_arg);

  DataState<Note> read() => _ref.read(_provider);
  DataState<Note> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(R Function(DataState<Note> state) selector) =>
      SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(DataState<Note>? previous, DataState<Note> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Note>>(_provider, listener, onError: onError);
  }
}

class $NoteDetailFacadeWidget
    implements
        DataProviderFacade<Note>,
        DataProviderValue<Note, ({String id})> {
  $NoteDetailFacadeWidget(this._ref, this._arg);
  final WidgetRef _ref;
  final ({String id}) _arg;

  late final _provider = _noteDetailProvider(_arg);

  @override
  DataState<Note> read() => _ref.read(_provider);
  @override
  DataState<Note> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<Note> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  Future<void> reload() => _ref.watch(_provider.notifier).reload();

  @override
  Future<void> silentReload() => _ref.watch(_provider.notifier).silentReload();

  @override
  void listen(
    void Function(DataState<Note>? previous, DataState<Note> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Note>>(_provider, listener, onError: onError);
  }

  @override
  DataProviderFacade<Note> of(WidgetRef ref) =>
      $NoteDetailFacadeWidget(ref, _arg);
}

class $NoteDetailFacadeRefCallable {
  $NoteDetailFacadeRefCallable(this._ref);
  final Ref _ref;

  $NoteDetailFacadeRef call({required String id}) =>
      $NoteDetailFacadeRef(_ref, (id: id));

  void invalidateFamily() => _ref.invalidate(_noteDetailProvider);
}

class $NoteDetailFacadeWidgetCallable {
  $NoteDetailFacadeWidgetCallable(this._ref);
  final WidgetRef _ref;

  $NoteDetailFacadeWidget call({required String id}) =>
      $NoteDetailFacadeWidget(_ref, (id: id));

  void invalidateFamily() => _ref.invalidate(_noteDetailProvider);
}

extension NoteDetailFacadeRefEx on Ref {
  $NoteDetailFacadeRefCallable get noteDetailProvider =>
      $NoteDetailFacadeRefCallable(this);
}

extension NoteDetailFacadeWidgetRefEx on WidgetRef {
  $NoteDetailFacadeWidgetCallable get noteDetailProvider =>
      $NoteDetailFacadeWidgetCallable(this);
}
