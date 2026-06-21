import 'package:riverpod_craft/riverpod_craft.dart';

/// A value that resolves to a [ProviderFacade] for a given [WidgetRef].
abstract class ProviderValue<T> {
  /// Creates a [ProviderValue].
  const ProviderValue();

  /// Resolves this value into a [ProviderFacade] scoped to [ref].
  ProviderFacade<T> of(WidgetRef ref);
}

/// A value that resolves to a [DataProviderFacade] for a given [WidgetRef].
abstract class DataProviderValue<T, F> {
  /// Creates a [DataProviderValue].
  const DataProviderValue();

  /// Resolves this value into a [DataProviderFacade] scoped to [ref].
  DataProviderFacade<T, F> of(WidgetRef ref);
}

/// A value that resolves to a [PagedProviderFacade] for a given [WidgetRef].
abstract class PagedProviderValue<T, F> {
  /// Creates a [PagedProviderValue].
  const PagedProviderValue();

  /// Resolves this value into a [PagedProviderFacade] scoped to [ref].
  PagedProviderFacade<T, F> of(WidgetRef ref);
}

/// A value that resolves to a [CommandProviderFacade] for a given [WidgetRef].
abstract class CommandProviderValue<T, F, ArgT extends Record> {
  /// Creates a [CommandProviderValue].
  const CommandProviderValue();

  /// Resolves this value into a [CommandProviderFacade] scoped to [ref].
  CommandProviderFacade<T, F, ArgT> of(WidgetRef ref);
}
