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
    NotifierProvider<$$Countries, DataState<List<String>>>(
      () => $$Countries()..arg = (),
      isAutoDispose: true,
    );

class $$Countries extends DataNotifier<List<String>, ()> {
  @override
  bool get isFuture => true;

  @override
  Future<List<String>> buildDataWithFuture() => countries(ref);
}

class $CountriesFacadeRef {
  $CountriesFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _countriesProvider;

  DataState<List<String>> read() => _ref.read(_provider);
  DataState<List<String>> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(DataState<List<String>> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void listen(
    void Function(
      DataState<List<String>>? previous,
      DataState<List<String>> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<List<String>>>(_provider, listener, onError: onError);
  }
}

class $CountriesFacadeWidget
    implements
        DataProviderFacade<List<String>>,
        DataProviderValue<List<String>> {
  $CountriesFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _countriesProvider;

  @override
  DataState<List<String>> read() => _ref.read(_provider);
  @override
  DataState<List<String>> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(DataState<List<String>> state) selector,
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
      DataState<List<String>>? previous,
      DataState<List<String>> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<DataState<List<String>>>(_provider, listener, onError: onError);
  }

  @override
  DataProviderFacade<List<String>> of(WidgetRef ref) =>
      $CountriesFacadeWidget(ref);
}

extension CountriesFacadeRefEx on Ref {
  $CountriesFacadeRef get countriesProvider => $CountriesFacadeRef(this);
}

extension CountriesFacadeWidgetRefEx on WidgetRef {
  $CountriesFacadeWidget get countriesProvider => $CountriesFacadeWidget(this);
}

final _countriesPagedProvider =
    NotifierProvider<$$CountriesPaged, PagedDataState<String>>(
      () => $$CountriesPaged()..arg = (),
      isAutoDispose: true,
    );

class $$CountriesPaged extends PagedDataNotifier<String, ()> {
  @override
  Future<PaginatedResponse<String>> buildPagedData(int page) =>
      countriesPaged(ref, page);
}

class $CountriesPagedFacadeRef {
  $CountriesPagedFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _countriesPagedProvider;

  PagedDataState<String> read() => _ref.read(_provider);
  PagedDataState<String> watch() => _ref.watch(_provider);

  SelectedRefFacade<R> select<R>(
    R Function(PagedDataState<String> state) selector,
  ) => SelectedRefFacade(_ref, _provider.select(selector));

  void invalidate() => _ref.invalidate(_provider);

  void fetchNextPage() => _ref.read(_provider.notifier).fetchNextPage();
  Future<void> reload() => _ref.read(_provider.notifier).reload();

  void listen(
    void Function(PagedDataState<String>? previous, PagedDataState<String> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<PagedDataState<String>>(_provider, listener, onError: onError);
  }
}

class $CountriesPagedFacadeWidget
    implements PagedProviderFacade<String>, PagedProviderValue<String> {
  $CountriesPagedFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _countriesPagedProvider;

  PagedDataState<String> read() => _ref.read(_provider);
  PagedDataState<String> watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(PagedDataState<String> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  @override
  void fetchNextPage() => _ref.read(_provider.notifier).fetchNextPage();

  Future<void> reload() => _ref.read(_provider.notifier).reload();

  void listen(
    void Function(PagedDataState<String>? previous, PagedDataState<String> next)
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<PagedDataState<String>>(_provider, listener, onError: onError);
  }

  @override
  PagedProviderFacade<String> of(WidgetRef ref) =>
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
