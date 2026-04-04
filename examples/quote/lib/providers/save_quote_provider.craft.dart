part of 'save_quote_provider.dart';

final _$saveQuoteCommand =
    NotifierProvider<
      CommandNotifier<String, ({String quoteId})>,
      ArgCommandState<String, ({String quoteId})>
    >(() => _$SaveQuoteCommand(), isAutoDispose: true);

class _$SaveQuoteCommand extends CommandNotifier<String, ({String quoteId})> {
  @override
  Future<String> action(Ref ref, ({String quoteId}) arg) =>
      saveQuote(ref, quoteId: arg.quoteId);

  @override
  List<Ref> get refs => [];

  @override
  ActionStrategy get strategy => ActionStrategy.droppable;
}

class $SaveQuoteCommandFacadeRef {
  $SaveQuoteCommandFacadeRef(this._ref);

  final Ref _ref;

  late final _command = _$saveQuoteCommand;

  ArgCommandState<String, ({String quoteId})> read() => _ref.read(_command);
  ArgCommandState<String, ({String quoteId})> watch() => _ref.watch(_command);

  SelectedRefFacade<R> select<R>(
    R Function(ArgCommandState<String, ({String quoteId})> state) selector,
  ) => SelectedRefFacade(_ref, _command.select(selector));

  void run({required String quoteId}) =>
      _ref.read(_command.notifier).add((quoteId: quoteId));
  void reset() => _ref.read(_command.notifier).reset();
  void retry() => _ref.read(_command.notifier).retry();
  void listen(
    void Function(
      ArgCommandState<String, ({String quoteId})>? previous,
      ArgCommandState<String, ({String quoteId})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }
}

class $SaveQuoteCommandFacadeWidget
    implements
        CommandProviderFacade<String, ({String quoteId})>,
        CommandProviderValue<String, ({String quoteId})> {
  $SaveQuoteCommandFacadeWidget(this._ref);

  final WidgetRef _ref;

  late final _command = _$saveQuoteCommand;

  @override
  ArgCommandState<String, ({String quoteId})> read() => _ref.read(_command);
  @override
  ArgCommandState<String, ({String quoteId})> watch() => _ref.watch(_command);

  SelectedWidgetRefFacade<R> select<R>(
    R Function(ArgCommandState<String, ({String quoteId})> state) selector,
  ) => SelectedWidgetRefFacade(_ref, _command.select(selector));

  void run({required String quoteId}) =>
      _ref.read(_command.notifier).add((quoteId: quoteId));
  @override
  void reset() => _ref.read(_command.notifier).reset();
  @override
  void retry() => _ref.read(_command.notifier).retry();
  @override
  void invalidate() => _ref.invalidate(_command);
  @override
  void listen(
    void Function(
      ArgCommandState<String, ({String quoteId})>? previous,
      ArgCommandState<String, ({String quoteId})> next,
    )
    listener, {
    void Function(Object, StackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ref.listen(_command, listener, onError: onError);
  }

  @override
  CommandProviderFacade<String, ({String quoteId})> of(WidgetRef ref) =>
      $SaveQuoteCommandFacadeWidget(ref);
}

extension $SaveQuoteCommandRefEx on Ref {
  $SaveQuoteCommandFacadeRef get saveQuoteCommand =>
      $SaveQuoteCommandFacadeRef(this);
}

extension $SaveQuoteCommandWidgetRefEx on WidgetRef {
  $SaveQuoteCommandFacadeWidget get saveQuoteCommand =>
      $SaveQuoteCommandFacadeWidget(this);
}
