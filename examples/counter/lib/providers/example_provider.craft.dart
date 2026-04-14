// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
part of 'example_provider.dart';

final _namesProvider = NotifierProvider<$$Names, List<String>>(
  () => $$Names()..arg = (),
  isAutoDispose: true,
);

class $$Names extends StateDataNotifier<List<String>, ()> {
  @override
  List<String> buildData(() arg) => names(ref);
}

class $NamesFacadeRef {
  $NamesFacadeRef(this._ref);
  final Ref _ref;

  late final _provider = _namesProvider;

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

class $NamesFacadeWidget
    implements ProviderFacade<List<String>>, ProviderValue<List<String>> {
  $NamesFacadeWidget(this._ref);
  final WidgetRef _ref;

  late final _provider = _namesProvider;

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
  ProviderFacade<List<String>> of(WidgetRef ref) => $NamesFacadeWidget(ref);
}

extension NamesFacadeRefEx on Ref {
  $NamesFacadeRef get namesProvider => $NamesFacadeRef(this);
}

extension NamesFacadeWidgetRefEx on WidgetRef {
  $NamesFacadeWidget get namesProvider => $NamesFacadeWidget(this);
}
