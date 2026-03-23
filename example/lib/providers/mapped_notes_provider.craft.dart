part of 'mapped_notes_provider.dart';

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

abstract class _$MappedNotes
    extends PagedDataNotifier<Note, ({String? category})> {
  Paged<Note> create(int page, {required String? category});
  @override
  Future<PaginatedResponse<Note>> buildPagedData(int page) async =>
      pagedMapper(await create(page, category: arg.category));
}

final _mappedNotesProvider =
    NotifierProvider.family<
      MappedNotes,
      PagedDataState<Note>,
      ({String? category})
    >(
      (({String? category}) arg) => MappedNotes()..arg = arg,
      isAutoDispose: true,
    );

class $MappedNotesFacadeRef {
  $MappedNotesFacadeRef(this._ref, this._arg);
  final Ref _ref;
  final ({String? category}) _arg;

  late final _provider = _mappedNotesProvider(_arg);

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
}

class $MappedNotesFacadeWidget
    implements PagedDataProviderFacade<Note>, PagedProviderValue<Note> {
  $MappedNotesFacadeWidget(this._ref, this._arg);
  final WidgetRef _ref;
  final ({String? category}) _arg;

  late final _provider = _mappedNotesProvider(_arg);

  @override
  PagedDataState<Note> read() => _ref.read(_provider);
  @override
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
  PagedDataProviderFacade<Note> of(WidgetRef ref) =>
      $MappedNotesFacadeWidget(ref, _arg);
}

class $MappedNotesFacadeRefCallable {
  $MappedNotesFacadeRefCallable(this._ref);
  final Ref _ref;

  $MappedNotesFacadeRef call({required String? category}) =>
      $MappedNotesFacadeRef(_ref, (category: category));

  void invalidateFamily() => _ref.invalidate(_mappedNotesProvider);
}

class $MappedNotesFacadeWidgetCallable {
  $MappedNotesFacadeWidgetCallable(this._ref);
  final WidgetRef _ref;

  $MappedNotesFacadeWidget call({required String? category}) =>
      $MappedNotesFacadeWidget(_ref, (category: category));

  void invalidateFamily() => _ref.invalidate(_mappedNotesProvider);
}

extension MappedNotesFacadeRefEx on Ref {
  $MappedNotesFacadeRefCallable get mappedNotesProvider =>
      $MappedNotesFacadeRefCallable(this);
}

extension MappedNotesFacadeWidgetRefEx on WidgetRef {
  $MappedNotesFacadeWidgetCallable get mappedNotesProvider =>
      $MappedNotesFacadeWidgetCallable(this);
}

abstract class _$XMappedNotes
    extends PagedDataNotifier<Note, ({String? category})> {
  Paged<Note> create(int page, {required String? category});
  @override
  Future<PaginatedResponse<Note>> buildPagedData(int page) async =>
      pagedMapper(await create(page, category: arg.category));
}

final _xMappedNotesProvider =
    NotifierProvider.family<
      XMappedNotes,
      PagedDataState<Note>,
      ({String? category})
    >(
      (({String? category}) arg) => XMappedNotes()..arg = arg,
      isAutoDispose: true,
    );

class $XMappedNotesFacadeRef {
  $XMappedNotesFacadeRef(this._ref, this._arg);
  final Ref _ref;
  final ({String? category}) _arg;

  late final _provider = _xMappedNotesProvider(_arg);

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
}

class $XMappedNotesFacadeWidget
    implements PagedDataProviderFacade<Note>, PagedProviderValue<Note> {
  $XMappedNotesFacadeWidget(this._ref, this._arg);
  final WidgetRef _ref;
  final ({String? category}) _arg;

  late final _provider = _xMappedNotesProvider(_arg);

  @override
  PagedDataState<Note> read() => _ref.read(_provider);
  @override
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
  PagedDataProviderFacade<Note> of(WidgetRef ref) =>
      $XMappedNotesFacadeWidget(ref, _arg);
}

class $XMappedNotesFacadeRefCallable {
  $XMappedNotesFacadeRefCallable(this._ref);
  final Ref _ref;

  $XMappedNotesFacadeRef call({required String? category}) =>
      $XMappedNotesFacadeRef(_ref, (category: category));

  void invalidateFamily() => _ref.invalidate(_xMappedNotesProvider);
}

class $XMappedNotesFacadeWidgetCallable {
  $XMappedNotesFacadeWidgetCallable(this._ref);
  final WidgetRef _ref;

  $XMappedNotesFacadeWidget call({required String? category}) =>
      $XMappedNotesFacadeWidget(_ref, (category: category));

  void invalidateFamily() => _ref.invalidate(_xMappedNotesProvider);
}

extension XMappedNotesFacadeRefEx on Ref {
  $XMappedNotesFacadeRefCallable get xMappedNotesProvider =>
      $XMappedNotesFacadeRefCallable(this);
}

extension XMappedNotesFacadeWidgetRefEx on WidgetRef {
  $XMappedNotesFacadeWidgetCallable get xMappedNotesProvider =>
      $XMappedNotesFacadeWidgetCallable(this);
}
