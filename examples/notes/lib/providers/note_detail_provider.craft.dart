// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'note_detail_provider.dart';

AppError _$errorMapper(Object error) {
  final text = error.toString();
  if (text.contains('SocketException') || text.contains('Failed host lookup')) {
    return const NetworkError('No internet connection');
  }
  if (text.contains('404') || text.contains('Not Found')) {
    return const NotFoundError('The requested note was not found');
  }
  return UnknownError(text, error);
}

final _noteDetailProvider =
    NotifierProvider.family<
      $$NoteDetail,
      DataState<Note, AppError>,
      ({String id})
    >((({String id}) arg) => $$NoteDetail()..arg = arg, isAutoDispose: true);

class $$NoteDetail extends DataNotifier<Note, AppError, ({String id})> {
  @override
  bool get isFuture => true;

  @override
  Future<Note> buildDataWithFuture() => noteDetail(ref, id: arg.id);

  @override
  AppError mapError(Object error) => _$errorMapper(error);
}

class $NoteDetailFacadeRef {
  $NoteDetailFacadeRef(this._ref, this._arg);
  final Ref _ref;
  final ({String id}) _arg;

  late final _provider = _noteDetailProvider(_arg);

  DataState<Note, AppError> read() => _ref.read(_provider);
  DataState<Note, AppError> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<Note, AppError> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  DataFuture<Note, AppError> get future => DataFuture(
    DataWatchHandle<Note, AppError>(
      read: () => _ref.read(_provider),
      reload: () => _ref.read(_provider.notifier).reload(),
      listen: (listener) => _ref.listen(_provider, listener),
      invalidateSelf: () => _ref.invalidateSelf(),
    ),
    (forceRefetch) =>
        _ref.read(_provider.notifier).future(forceRefetch: forceRefetch),
  );

  void listen(
    void Function(
      DataState<Note, AppError>? previous,
      DataState<Note, AppError> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Note, AppError>>(
      _provider,
      listener,
      onError: onError,
    );
  }
}

class $NoteDetailFacadeWidget
    implements
        DataProviderFacade<Note, AppError>,
        DataProviderValue<Note, AppError> {
  $NoteDetailFacadeWidget(this._ref, this._arg);
  final WidgetRef _ref;
  final ({String id}) _arg;

  late final _provider = _noteDetailProvider(_arg);

  @override
  DataState<Note, AppError> read() => _ref.read(_provider);
  @override
  DataState<Note, AppError> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<Note, AppError> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  Future<void> reload() => _ref.watch(_provider.notifier).reload();

  @override
  Future<void> silentReload() => _ref.watch(_provider.notifier).silentReload();

  @override
  void listen(
    void Function(
      DataState<Note, AppError>? previous,
      DataState<Note, AppError> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<Note, AppError>>(
      _provider,
      listener,
      onError: onError,
    );
  }

  @override
  DataProviderFacade<Note, AppError> of(WidgetRef ref) =>
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
