// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'notes_provider.dart';

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

abstract class _$Notes extends DataNotifier<List<Note>, AppError, ()> {
  @override
  bool get isFuture => true;

  Future<List<Note>> create();
  @override
  Future<List<Note>> buildDataWithFuture() => create();

  @override
  AppError mapError(Object error) => _$errorMapper(error);

  Future<Note> addNote({
    required String title,
    required String body,
    required NoteCategory category,
  });

  late final _$addNoteCommand =
      NotifierProvider<
        CommandNotifier<
          Note,
          AppError,
          ({String title, String body, NoteCategory category})
        >,
        ArgCommandState<
          Note,
          AppError,
          ({String title, String body, NoteCategory category})
        >
      >(() => _$AddNoteCommandNotes(this as Notes), isAutoDispose: true);

  $AddNoteCommandFacadeNotesRef get addNoteCommand =>
      $AddNoteCommandFacadeNotesRef(ref, this as Notes);
  Future<String> deleteNote({required String id});

  late final _$deleteNoteCommand =
      NotifierProvider<
        CommandNotifier<String, AppError, ({String id})>,
        ArgCommandState<String, AppError, ({String id})>
      >(() => _$DeleteNoteCommandNotes(this as Notes), isAutoDispose: true);

  $DeleteNoteCommandFacadeNotesRef get deleteNoteCommand =>
      $DeleteNoteCommandFacadeNotesRef(ref, this as Notes);
  Future<Note> updateNote({required Note note});

  late final _$updateNoteCommand =
      NotifierProvider<
        CommandNotifier<Note, AppError, ({Note note})>,
        ArgCommandState<Note, AppError, ({Note note})>
      >(() => _$UpdateNoteCommandNotes(this as Notes), isAutoDispose: true);

  $UpdateNoteCommandFacadeNotesRef get updateNoteCommand =>
      $UpdateNoteCommandFacadeNotesRef(ref, this as Notes);
}

final _notesProvider = NotifierProvider<Notes, DataState<List<Note>, AppError>>(
  () => Notes()..arg = (),
  isAutoDispose: true,
);

class $NotesFacadeRef {
  $NotesFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _notesProvider;

  DataState<List<Note>, AppError> read() => _ref.read(_provider);
  DataState<List<Note>, AppError> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<List<Note>, AppError> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  Future<List<Note>> future({bool watch = false, bool forceRefetch = false}) {
    if (!watch) {
      return _ref.read(_provider.notifier).future(forceRefetch: forceRefetch);
    }
    return DataWatchHandle<List<Note>, AppError>(
      read: () => _ref.read(_provider),
      reload: () => _ref.read(_provider.notifier).reload(),
      listen: (listener) => _ref.listen(_provider, listener),
      invalidateSelf: () => _ref.invalidateSelf(),
    ).future(forceRefetch: forceRefetch);
  }

  void listen(
    void Function(
      DataState<List<Note>, AppError>? previous,
      DataState<List<Note>, AppError> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<List<Note>, AppError>>(
      _provider,
      listener,
      onError: onError,
    );
  }

  $AddNoteCommandFacadeNotesRef get addNoteCommand =>
      $AddNoteCommandFacadeNotesRef(_ref, _ref.read(_provider.notifier));
  $DeleteNoteCommandFacadeNotesRef get deleteNoteCommand =>
      $DeleteNoteCommandFacadeNotesRef(_ref, _ref.read(_provider.notifier));
  $UpdateNoteCommandFacadeNotesRef get updateNoteCommand =>
      $UpdateNoteCommandFacadeNotesRef(_ref, _ref.read(_provider.notifier));
}

class $NotesFacadeWidget
    implements
        DataProviderFacade<List<Note>, AppError>,
        DataProviderValue<List<Note>, AppError> {
  $NotesFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _notesProvider;

  @override
  DataState<List<Note>, AppError> read() => _ref.read(_provider);
  @override
  DataState<List<Note>, AppError> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<List<Note>, AppError> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  Future<void> reload() => _ref.watch(_provider.notifier).reload();

  @override
  Future<void> silentReload() => _ref.watch(_provider.notifier).silentReload();
  Future<List<Note>> future({bool forceRefetch = false}) =>
      _ref.read(_provider.notifier).future(forceRefetch: forceRefetch);

  @override
  void listen(
    void Function(
      DataState<List<Note>, AppError>? previous,
      DataState<List<Note>, AppError> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<List<Note>, AppError>>(
      _provider,
      listener,
      onError: onError,
    );
  }

  @override
  DataProviderFacade<List<Note>, AppError> of(WidgetRef ref) =>
      $NotesFacadeWidget(ref);

  $AddNoteCommandFacadeNotesWidget get addNoteCommand =>
      $AddNoteCommandFacadeNotesWidget(_ref, _ref.read(_provider.notifier));
  $DeleteNoteCommandFacadeNotesWidget get deleteNoteCommand =>
      $DeleteNoteCommandFacadeNotesWidget(_ref, _ref.read(_provider.notifier));
  $UpdateNoteCommandFacadeNotesWidget get updateNoteCommand =>
      $UpdateNoteCommandFacadeNotesWidget(_ref, _ref.read(_provider.notifier));
}

class _$AddNoteCommandNotes
    extends
        CommandNotifier<
          Note,
          AppError,
          ({String title, String body, NoteCategory category})
        > {
  _$AddNoteCommandNotes(this._instance);
  final Notes _instance;

  @override
  Future<Note> action(
    Ref ref,
    ({String title, String body, NoteCategory category}) arg,
  ) => _instance.addNote(
    title: arg.title,
    body: arg.body,
    category: arg.category,
  );

  @override
  List<Ref> get refs => [_instance.ref];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;

  @override
  AppError mapError(Object error) => _$errorMapper(error);
}

class _$DeleteNoteCommandNotes
    extends CommandNotifier<String, AppError, ({String id})> {
  _$DeleteNoteCommandNotes(this._instance);
  final Notes _instance;

  @override
  Future<String> action(Ref ref, ({String id}) arg) =>
      _instance.deleteNote(id: arg.id);

  @override
  List<Ref> get refs => [_instance.ref];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;

  @override
  AppError mapError(Object error) => _$errorMapper(error);
}

class _$UpdateNoteCommandNotes
    extends CommandNotifier<Note, AppError, ({Note note})> {
  _$UpdateNoteCommandNotes(this._instance);
  final Notes _instance;

  @override
  Future<Note> action(Ref ref, ({Note note}) arg) =>
      _instance.updateNote(note: arg.note);

  @override
  List<Ref> get refs => [_instance.ref];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;

  @override
  AppError mapError(Object error) => _$errorMapper(error);
}

class $AddNoteCommandFacadeNotesRef {
  $AddNoteCommandFacadeNotesRef(this._ref, this._instance);
  final Notes _instance;

  final Ref _ref;

  late final _command = _instance._$addNoteCommand;

  ArgCommandState<
    Note,
    AppError,
    ({String title, String body, NoteCategory category})
  >
  read() => _ref.read(_command);
  ArgCommandState<
    Note,
    AppError,
    ({String title, String body, NoteCategory category})
  >
  watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(
      ArgCommandState<
        Note,
        AppError,
        ({String title, String body, NoteCategory category})
      >
      state,
    )
    selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run({
    required String title,
    required String body,
    required NoteCategory category,
  }) => _ref.read(_command.notifier).add((
    title: title,
    body: body,
    category: category,
  ));
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<
        Note,
        AppError,
        ({String title, String body, NoteCategory category})
      >?
      previous,
      ArgCommandState<
        Note,
        AppError,
        ({String title, String body, NoteCategory category})
      >
      next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $DeleteNoteCommandFacadeNotesRef {
  $DeleteNoteCommandFacadeNotesRef(this._ref, this._instance);
  final Notes _instance;

  final Ref _ref;

  late final _command = _instance._$deleteNoteCommand;

  ArgCommandState<String, AppError, ({String id})> read() =>
      _ref.read(_command);
  ArgCommandState<String, AppError, ({String id})> watch() =>
      _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<String, AppError, ({String id})> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run({required String id}) => _ref.read(_command.notifier).add((id: id));
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<String, AppError, ({String id})>? previous,
      ArgCommandState<String, AppError, ({String id})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $UpdateNoteCommandFacadeNotesRef {
  $UpdateNoteCommandFacadeNotesRef(this._ref, this._instance);
  final Notes _instance;

  final Ref _ref;

  late final _command = _instance._$updateNoteCommand;

  ArgCommandState<Note, AppError, ({Note note})> read() => _ref.read(_command);
  ArgCommandState<Note, AppError, ({Note note})> watch() =>
      _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<Note, AppError, ({Note note})> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run({required Note note}) =>
      _ref.read(_command.notifier).add((note: note));
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<Note, AppError, ({Note note})>? previous,
      ArgCommandState<Note, AppError, ({Note note})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $AddNoteCommandFacadeNotesWidget
    implements
        CommandProviderFacade<
          Note,
          AppError,
          ({String title, String body, NoteCategory category})
        >,
        CommandProviderValue<
          Note,
          AppError,
          ({String title, String body, NoteCategory category})
        > {
  $AddNoteCommandFacadeNotesWidget(this._ref, this._instance);
  final Notes _instance;

  final WidgetRef _ref;

  late final _command = _instance._$addNoteCommand;

  @override
  ArgCommandState<
    Note,
    AppError,
    ({String title, String body, NoteCategory category})
  >
  read() => _ref.read(_command);
  @override
  ArgCommandState<
    Note,
    AppError,
    ({String title, String body, NoteCategory category})
  >
  watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(
      ArgCommandState<
        Note,
        AppError,
        ({String title, String body, NoteCategory category})
      >
      state,
    )
    selector,
  ) => SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run({
    required String title,
    required String body,
    required NoteCategory category,
  }) => _ref.read(_command.notifier).add((
    title: title,
    body: body,
    category: category,
  ));
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(
      ArgCommandState<
        Note,
        AppError,
        ({String title, String body, NoteCategory category})
      >?
      previous,
      ArgCommandState<
        Note,
        AppError,
        ({String title, String body, NoteCategory category})
      >
      next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<
    Note,
    AppError,
    ({String title, String body, NoteCategory category})
  >
  of(WidgetRef ref) => $AddNoteCommandFacadeNotesWidget(ref, _instance);
}

class $DeleteNoteCommandFacadeNotesWidget
    implements
        CommandProviderFacade<String, AppError, ({String id})>,
        CommandProviderValue<String, AppError, ({String id})> {
  $DeleteNoteCommandFacadeNotesWidget(this._ref, this._instance);
  final Notes _instance;

  final WidgetRef _ref;

  late final _command = _instance._$deleteNoteCommand;

  @override
  ArgCommandState<String, AppError, ({String id})> read() =>
      _ref.read(_command);
  @override
  ArgCommandState<String, AppError, ({String id})> watch() =>
      _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<String, AppError, ({String id})> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run({required String id}) => _ref.read(_command.notifier).add((id: id));
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(
      ArgCommandState<String, AppError, ({String id})>? previous,
      ArgCommandState<String, AppError, ({String id})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<String, AppError, ({String id})> of(WidgetRef ref) =>
      $DeleteNoteCommandFacadeNotesWidget(ref, _instance);
}

class $UpdateNoteCommandFacadeNotesWidget
    implements
        CommandProviderFacade<Note, AppError, ({Note note})>,
        CommandProviderValue<Note, AppError, ({Note note})> {
  $UpdateNoteCommandFacadeNotesWidget(this._ref, this._instance);
  final Notes _instance;

  final WidgetRef _ref;

  late final _command = _instance._$updateNoteCommand;

  @override
  ArgCommandState<Note, AppError, ({Note note})> read() => _ref.read(_command);
  @override
  ArgCommandState<Note, AppError, ({Note note})> watch() =>
      _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<Note, AppError, ({Note note})> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run({required Note note}) =>
      _ref.read(_command.notifier).add((note: note));
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(
      ArgCommandState<Note, AppError, ({Note note})>? previous,
      ArgCommandState<Note, AppError, ({Note note})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<Note, AppError, ({Note note})> of(WidgetRef ref) =>
      $UpdateNoteCommandFacadeNotesWidget(ref, _instance);
}

extension NotesFacadeRefEx on Ref {
  $NotesFacadeRef get notesProvider => $NotesFacadeRef(this);
}

extension NotesFacadeWidgetRefEx on WidgetRef {
  $NotesFacadeWidget get notesProvider => $NotesFacadeWidget(this);
}
