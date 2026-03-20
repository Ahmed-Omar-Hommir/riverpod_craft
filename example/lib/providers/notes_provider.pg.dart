part of 'notes_provider.dart';

abstract class _$Notes extends DataNotifier<List<Note>, ()> {
  @override
  bool get isFuture => true;

  Future<List<Note>> create();
  @override
  Future<List<Note>> buildDataWithFuture() => create();

  Future<Note> addNote({
    required String title,
    required String body,
    required NoteCategory category,
  });

  late final _$addNoteCommand = NotifierProvider(
    () => _$AddNoteCommandNotes(this as Notes),
    isAutoDispose: true,
  );

  $AddNoteCommandFacadeNotesRef get addNoteCommand =>
      $AddNoteCommandFacadeNotesRef(ref, this as Notes);
  Future<String> deleteNote({required String id});

  late final _$deleteNoteCommand = NotifierProvider(
    () => _$DeleteNoteCommandNotes(this as Notes),
    isAutoDispose: true,
  );

  $DeleteNoteCommandFacadeNotesRef get deleteNoteCommand =>
      $DeleteNoteCommandFacadeNotesRef(ref, this as Notes);
  Future<Note> updateNote({required Note note});

  late final _$updateNoteCommand = NotifierProvider(
    () => _$UpdateNoteCommandNotes(this as Notes),
    isAutoDispose: true,
  );

  $UpdateNoteCommandFacadeNotesRef get updateNoteCommand =>
      $UpdateNoteCommandFacadeNotesRef(ref, this as Notes);
}

final _notesProvider = NotifierProvider(
  () => Notes()..arg = (),
  isAutoDispose: true,
);

class $NotesFacadeRef {
  $NotesFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _notesProvider;

  DataState<List<Note>> read() => _ref.read(_provider);
  DataState<List<Note>> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<List<Note>> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(DataState<List<Note>>? previous, DataState<List<Note>> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<List<Note>>>(_provider, listener, onError: onError);
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
        DataProviderFacade<List<Note>>,
        DataProviderValue<List<Note>, ()> {
  $NotesFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _notesProvider;

  @override
  DataState<List<Note>> read() => _ref.read(_provider);
  @override
  DataState<List<Note>> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<List<Note>> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  Future<void> reload() => _ref.watch(_provider.notifier).reload();

  @override
  Future<void> silentReload() => _ref.watch(_provider.notifier).silentReload();

  @override
  void listen(
    void Function(DataState<List<Note>>? previous, DataState<List<Note>> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<List<Note>>>(_provider, listener, onError: onError);
  }

  @override
  DataProviderFacade<List<Note>> of(WidgetRef ref) => $NotesFacadeWidget(ref);

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
}

class _$DeleteNoteCommandNotes extends CommandNotifier<String, ({String id})> {
  _$DeleteNoteCommandNotes(this._instance);
  final Notes _instance;

  @override
  Future<String> action(Ref ref, ({String id}) arg) =>
      _instance.deleteNote(id: arg.id);

  @override
  List<Ref> get refs => [_instance.ref];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;
}

class _$UpdateNoteCommandNotes extends CommandNotifier<Note, ({Note note})> {
  _$UpdateNoteCommandNotes(this._instance);
  final Notes _instance;

  @override
  Future<Note> action(Ref ref, ({Note note}) arg) =>
      _instance.updateNote(note: arg.note);

  @override
  List<Ref> get refs => [_instance.ref];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;
}

class $AddNoteCommandFacadeNotesRef {
  $AddNoteCommandFacadeNotesRef(this._ref, this._instance);
  final Notes _instance;

  final Ref _ref;

  late final _command = _instance._$addNoteCommand;

  ArgCommandState<Note, ({String title, String body, NoteCategory category})>
  read() => _ref.read(_command);
  ArgCommandState<Note, ({String title, String body, NoteCategory category})>
  watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(
      ArgCommandState<
        Note,
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
        ({String title, String body, NoteCategory category})
      >?
      previous,
      ArgCommandState<
        Note,
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

  ArgCommandState<String, ({String id})> read() => _ref.read(_command);
  ArgCommandState<String, ({String id})> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<String, ({String id})> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run({required String id}) => _ref.read(_command.notifier).add((id: id));
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<String, ({String id})>? previous,
      ArgCommandState<String, ({String id})> next,
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

  ArgCommandState<Note, ({Note note})> read() => _ref.read(_command);
  ArgCommandState<Note, ({Note note})> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<Note, ({Note note})> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run({required Note note}) =>
      _ref.read(_command.notifier).add((note: note));
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<Note, ({Note note})>? previous,
      ArgCommandState<Note, ({Note note})> next,
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
          ({String title, String body, NoteCategory category})
        >,
        CommandProviderValue<
          Note,
          ({String title, String body, NoteCategory category})
        > {
  $AddNoteCommandFacadeNotesWidget(this._ref, this._instance);
  final Notes _instance;

  final WidgetRef _ref;

  late final _command = _instance._$addNoteCommand;

  @override
  ArgCommandState<Note, ({String title, String body, NoteCategory category})>
  read() => _ref.read(_command);
  @override
  ArgCommandState<Note, ({String title, String body, NoteCategory category})>
  watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(
      ArgCommandState<
        Note,
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
        ({String title, String body, NoteCategory category})
      >?
      previous,
      ArgCommandState<
        Note,
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
    ({String title, String body, NoteCategory category})
  >
  of(WidgetRef ref) => $AddNoteCommandFacadeNotesWidget(ref, _instance);
}

class $DeleteNoteCommandFacadeNotesWidget
    implements
        CommandProviderFacade<String, ({String id})>,
        CommandProviderValue<String, ({String id})> {
  $DeleteNoteCommandFacadeNotesWidget(this._ref, this._instance);
  final Notes _instance;

  final WidgetRef _ref;

  late final _command = _instance._$deleteNoteCommand;

  @override
  ArgCommandState<String, ({String id})> read() => _ref.read(_command);
  @override
  ArgCommandState<String, ({String id})> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<String, ({String id})> state) selector,
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
      ArgCommandState<String, ({String id})>? previous,
      ArgCommandState<String, ({String id})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<String, ({String id})> of(WidgetRef ref) =>
      $DeleteNoteCommandFacadeNotesWidget(ref, _instance);
}

class $UpdateNoteCommandFacadeNotesWidget
    implements
        CommandProviderFacade<Note, ({Note note})>,
        CommandProviderValue<Note, ({Note note})> {
  $UpdateNoteCommandFacadeNotesWidget(this._ref, this._instance);
  final Notes _instance;

  final WidgetRef _ref;

  late final _command = _instance._$updateNoteCommand;

  @override
  ArgCommandState<Note, ({Note note})> read() => _ref.read(_command);
  @override
  ArgCommandState<Note, ({Note note})> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<Note, ({Note note})> state) selector,
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
      ArgCommandState<Note, ({Note note})>? previous,
      ArgCommandState<Note, ({Note note})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<Note, ({Note note})> of(WidgetRef ref) =>
      $UpdateNoteCommandFacadeNotesWidget(ref, _instance);
}

extension NotesFacadeRefEx on Ref {
  $NotesFacadeRef get notesProvider => $NotesFacadeRef(this);
}

extension NotesFacadeWidgetRefEx on WidgetRef {
  $NotesFacadeWidget get notesProvider => $NotesFacadeWidget(this);
}
