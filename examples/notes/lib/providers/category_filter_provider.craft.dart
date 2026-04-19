// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'category_filter_provider.dart';

final _categoryFilterProvider =
    NotifierProvider<$$CategoryFilter, NoteCategory>(
      () => $$CategoryFilter()..arg = (),
      isAutoDispose: true,
    );

class $$CategoryFilter extends StateDataNotifier<NoteCategory, ()> {
  @override
  NoteCategory buildData(() arg) => categoryFilter(ref);
}

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
      _ref.read(_provider.notifier).state = value;

  void listen(
    void Function(NoteCategory? previous, NoteCategory next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<NoteCategory>(_provider, listener, onError: onError);
  }
}

class $CategoryFilterFacadeWidget
    implements ProviderFacade<NoteCategory>, ProviderValue<NoteCategory> {
  $CategoryFilterFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _categoryFilterProvider;

  @override
  NoteCategory read() => _ref.read(_provider);
  @override
  NoteCategory watch() => _ref.watch(_provider);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(NoteCategory state) selector,
  ) => SelectedWidgetRefFacade(_ref, _provider.select(selector));
  @override
  void invalidate() => _ref.invalidate(_provider);

  void setState(NoteCategory value) =>
      _ref.read(_provider.notifier).state = value;

  @override
  void listen(
    void Function(NoteCategory? previous, NoteCategory next) listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen<NoteCategory>(_provider, listener, onError: onError);
  }

  @override
  ProviderFacade<NoteCategory> of(WidgetRef ref) =>
      $CategoryFilterFacadeWidget(ref);
}

extension CategoryFilterFacadeRefEx on Ref {
  $CategoryFilterFacadeRef get categoryFilterProvider =>
      $CategoryFilterFacadeRef(this);
}

extension CategoryFilterFacadeWidgetRefEx on WidgetRef {
  $CategoryFilterFacadeWidget get categoryFilterProvider =>
      $CategoryFilterFacadeWidget(this);
}
