// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'paginated_notes_provider.dart';

typedef Paged<T> = Future<ApiPagedResponse<T>>;

PaginatedResponse<T> pagedMapper<T>(ApiPagedResponse<T> data) {
  return PaginatedResponse(
    results: data.items,
    currentPage: data.page,
    total: data.totalItems,
    lastPage: data.totalPages,
    pageSize: data.perPage,
  );
}

AppError errorMapper(Object error) {
  final text = error.toString();
  if (text.contains('SocketException') || text.contains('Failed host lookup')) {
    return const NetworkError('No internet connection');
  }
  if (text.contains('404') || text.contains('Not Found')) {
    return const NotFoundError('The requested note was not found');
  }
  return UnknownError(text, error);
}

abstract class _$PaginatedNotes
    extends PagedDataNotifier<Note, ({String? category})> {
  Paged<Note> create(int page, {required String? category});
  @override
  Future<PaginatedResponse<Note>> buildPagedData(int page) async =>
      pagedMapper(await create(page, category: arg.category));

  @override
  Object mapError(Object error) => errorMapper(error);

  Future<void> deleteNote({required String id});

  late final _$deleteNoteCommand =
      NotifierProvider<
        CommandNotifier<void, ({String id})>,
        ArgCommandState<void, ({String id})>
      >(
        () => _$DeleteNoteCommandPaginatedNotes(this as PaginatedNotes),
        isAutoDispose: true,
      );

  $DeleteNoteCommandFacadePaginatedNotesRef get deleteNoteCommand =>
      $DeleteNoteCommandFacadePaginatedNotesRef(ref, this as PaginatedNotes);
}

final _paginatedNotesProvider =
    NotifierProvider.family<
      PaginatedNotes,
      PagedDataState<Note>,
      ({String? category})
    >(
      (({String? category}) arg) => PaginatedNotes()..arg = arg,
      isAutoDispose: true,
    );

class $PaginatedNotesFacadeRef {
  $PaginatedNotesFacadeRef(this._ref, this._arg);
  final Ref _ref;
  final ({String? category}) _arg;

  late final _provider = _paginatedNotesProvider(_arg);

  PagedDataState<Note> read() => _ref.read(_provider);
  PagedDataState<Note> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(PagedDataState<Note> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void fetchNextPage() => _ref.read(_provider.notifier).fetchNextPage();
  Future<void> reload() => _ref.read(_provider.notifier).reload();

  void listen(
    void Function(PagedDataState<Note>? previous, PagedDataState<Note> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<PagedDataState<Note>>(_provider, listener, onError: onError);
  }

  $DeleteNoteCommandFacadePaginatedNotesRef get deleteNoteCommand =>
      $DeleteNoteCommandFacadePaginatedNotesRef(
        _ref,
        _ref.read(_provider.notifier),
      );
}

class $PaginatedNotesFacadeWidget
    implements PagedProviderFacade<Note>, PagedProviderValue<Note> {
  $PaginatedNotesFacadeWidget(this._ref, this._arg);
  final WidgetRef _ref;
  final ({String? category}) _arg;

  late final _provider = _paginatedNotesProvider(_arg);

  PagedDataState<Note> read() => _ref.read(_provider);
  PagedDataState<Note> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(PagedDataState<Note> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  void fetchNextPage() => _ref.read(_provider.notifier).fetchNextPage();

  Future<void> reload() => _ref.read(_provider.notifier).reload();

  void listen(
    void Function(PagedDataState<Note>? previous, PagedDataState<Note> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<PagedDataState<Note>>(_provider, listener, onError: onError);
  }

  @override
  PagedProviderFacade<Note> of(WidgetRef ref) =>
      $PaginatedNotesFacadeWidget(ref, _arg);

  $DeleteNoteCommandFacadePaginatedNotesWidget get deleteNoteCommand =>
      $DeleteNoteCommandFacadePaginatedNotesWidget(
        _ref,
        _ref.read(_provider.notifier),
      );
}

class _$DeleteNoteCommandPaginatedNotes
    extends CommandNotifier<void, ({String id})> {
  _$DeleteNoteCommandPaginatedNotes(this._instance);
  final PaginatedNotes _instance;

  @override
  Future<void> action(Ref ref, ({String id}) arg) =>
      _instance.deleteNote(id: arg.id);

  @override
  List<Ref> get refs => [_instance.ref];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;

  @override
  Object mapError(Object error) => errorMapper(error);
}

class $DeleteNoteCommandFacadePaginatedNotesRef {
  $DeleteNoteCommandFacadePaginatedNotesRef(this._ref, this._instance);
  final PaginatedNotes _instance;

  final Ref _ref;

  late final _command = _instance._$deleteNoteCommand;

  ArgCommandState<void, ({String id})> read() => _ref.read(_command);
  ArgCommandState<void, ({String id})> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<void, ({String id})> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run({required String id}) => _ref.read(_command.notifier).add((id: id));
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<void, ({String id})>? previous,
      ArgCommandState<void, ({String id})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $DeleteNoteCommandFacadePaginatedNotesWidget
    implements
        CommandProviderFacade<void, ({String id})>,
        CommandProviderValue<void, ({String id})> {
  $DeleteNoteCommandFacadePaginatedNotesWidget(this._ref, this._instance);
  final PaginatedNotes _instance;

  final WidgetRef _ref;

  late final _command = _instance._$deleteNoteCommand;

  @override
  ArgCommandState<void, ({String id})> read() => _ref.read(_command);
  @override
  ArgCommandState<void, ({String id})> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<void, ({String id})> state) selector,
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
      ArgCommandState<void, ({String id})>? previous,
      ArgCommandState<void, ({String id})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<void, ({String id})> of(WidgetRef ref) =>
      $DeleteNoteCommandFacadePaginatedNotesWidget(ref, _instance);
}

class $PaginatedNotesFacadeRefCallable {
  $PaginatedNotesFacadeRefCallable(this._ref);
  final Ref _ref;

  $PaginatedNotesFacadeRef call({required String? category}) =>
      $PaginatedNotesFacadeRef(_ref, (category: category));

  void invalidateFamily() => _ref.invalidate(_paginatedNotesProvider);
}

class $PaginatedNotesFacadeWidgetCallable {
  $PaginatedNotesFacadeWidgetCallable(this._ref);
  final WidgetRef _ref;

  $PaginatedNotesFacadeWidget call({required String? category}) =>
      $PaginatedNotesFacadeWidget(_ref, (category: category));

  void invalidateFamily() => _ref.invalidate(_paginatedNotesProvider);
}

extension PaginatedNotesFacadeRefEx on Ref {
  $PaginatedNotesFacadeRefCallable get paginatedNotesProvider =>
      $PaginatedNotesFacadeRefCallable(this);
}

extension PaginatedNotesFacadeWidgetRefEx on WidgetRef {
  $PaginatedNotesFacadeWidgetCallable get paginatedNotesProvider =>
      $PaginatedNotesFacadeWidgetCallable(this);
}
