// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'countries_provider.dart';

typedef Paged<T> = Future<PaginatedResponse<T>>;

final _featuredCountryProvider =
    NotifierProvider<$$FeaturedCountry, List<String>>(
      () => $$FeaturedCountry()..arg = (),
      isAutoDispose: true,
    );

class $$FeaturedCountry extends StateDataNotifier<List<String>, ()> {
  @override
  List<String> buildData(() arg) => featuredCountry(ref);
}

class $FeaturedCountryFacadeRef {
  $FeaturedCountryFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _featuredCountryProvider;

  List<String> read() => _ref.read(_provider);
  List<String> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(R Function(List<String> state) selector) =>
      SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(List<String>? previous, List<String> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<List<String>>(_provider, listener, onError: onError);
  }
}

class $FeaturedCountryFacadeWidget
    implements ProviderFacade<List<String>>, ProviderValue<List<String>> {
  $FeaturedCountryFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _featuredCountryProvider;

  @override
  List<String> read() => _ref.read(_provider);
  @override
  List<String> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(List<String> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  void listen(
    void Function(List<String>? previous, List<String> next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<List<String>>(_provider, listener, onError: onError);
  }

  @override
  ProviderFacade<List<String>> of(WidgetRef ref) =>
      $FeaturedCountryFacadeWidget(ref);
}

extension FeaturedCountryFacadeRefEx on Ref {
  $FeaturedCountryFacadeRef get featuredCountryProvider =>
      $FeaturedCountryFacadeRef(this);
}

extension FeaturedCountryFacadeWidgetRefEx on WidgetRef {
  $FeaturedCountryFacadeWidget get featuredCountryProvider =>
      $FeaturedCountryFacadeWidget(this);
}

final _countriesProvider =
    NotifierProvider<$$Countries, DataState<List<String>, Object>>(
      () => $$Countries()..arg = (),
      isAutoDispose: true,
    );

class $$Countries extends DataNotifier<List<String>, Object, ()> {
  @override
  bool get isFuture => true;

  @override
  Future<List<String>> buildDataWithFuture() => countries(ref);
}

class $CountriesFacadeRef {
  $CountriesFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _countriesProvider;

  DataState<List<String>, Object> read() => _ref.read(_provider);
  DataState<List<String>, Object> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<List<String>, Object> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(
      DataState<List<String>, Object>? previous,
      DataState<List<String>, Object> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<List<String>, Object>>(
      _provider,
      listener,
      onError: onError,
    );
  }
}

class $CountriesFacadeWidget
    implements
        DataProviderFacade<List<String>, Object>,
        DataProviderValue<List<String>, Object> {
  $CountriesFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _countriesProvider;

  @override
  DataState<List<String>, Object> read() => _ref.read(_provider);
  @override
  DataState<List<String>, Object> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<List<String>, Object> state) selector,
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
      DataState<List<String>, Object>? previous,
      DataState<List<String>, Object> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<List<String>, Object>>(
      _provider,
      listener,
      onError: onError,
    );
  }

  @override
  DataProviderFacade<List<String>, Object> of(WidgetRef ref) =>
      $CountriesFacadeWidget(ref);
}

extension CountriesFacadeRefEx on Ref {
  $CountriesFacadeRef get countriesProvider => $CountriesFacadeRef(this);
}

extension CountriesFacadeWidgetRefEx on WidgetRef {
  $CountriesFacadeWidget get countriesProvider => $CountriesFacadeWidget(this);
}

final _countriesPagedProvider =
    NotifierProvider<$$CountriesPaged, PagedDataState<String, Object>>(
      () => $$CountriesPaged()..arg = (),
      isAutoDispose: true,
    );

class $$CountriesPaged extends PagedDataNotifier<String, Object, ()> {
  @override
  Future<PaginatedResponse<String>> buildPagedData(int page) =>
      countriesPaged(ref, page);
}

class $CountriesPagedFacadeRef {
  $CountriesPagedFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _countriesPagedProvider;

  PagedDataState<String, Object> read() => _ref.read(_provider);
  PagedDataState<String, Object> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(PagedDataState<String, Object> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void fetchNextPage() => _ref.read(_provider.notifier).fetchNextPage();
  Future<void> reload() => _ref.read(_provider.notifier).reload();

  void listen(
    void Function(
      PagedDataState<String, Object>? previous,
      PagedDataState<String, Object> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<PagedDataState<String, Object>>(
      _provider,
      listener,
      onError: onError,
    );
  }
}

class $CountriesPagedFacadeWidget
    implements
        PagedProviderFacade<String, Object>,
        PagedProviderValue<String, Object> {
  $CountriesPagedFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _countriesPagedProvider;

  PagedDataState<String, Object> read() => _ref.read(_provider);
  PagedDataState<String, Object> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(PagedDataState<String, Object> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  void fetchNextPage() => _ref.read(_provider.notifier).fetchNextPage();

  Future<void> reload() => _ref.read(_provider.notifier).reload();

  void listen(
    void Function(
      PagedDataState<String, Object>? previous,
      PagedDataState<String, Object> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<PagedDataState<String, Object>>(
      _provider,
      listener,
      onError: onError,
    );
  }

  @override
  PagedProviderFacade<String, Object> of(WidgetRef ref) =>
      $CountriesPagedFacadeWidget(ref);
}

extension CountriesPagedFacadeRefEx on Ref {
  $CountriesPagedFacadeRef get countriesPagedProvider =>
      $CountriesPagedFacadeRef(this);
}

extension CountriesPagedFacadeWidgetRefEx on WidgetRef {
  $CountriesPagedFacadeWidget get countriesPagedProvider =>
      $CountriesPagedFacadeWidget(this);
}
