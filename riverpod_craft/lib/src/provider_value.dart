import 'package:riverpod_craft/riverpod_craft.dart';

abstract class ProviderValue<T> {
  const ProviderValue();

  ProviderFacade<T> of(WidgetRef ref);
}

abstract class DataProviderValue<T, ArgT extends Record> {
  const DataProviderValue();

  DataProviderFacade<T> of(WidgetRef ref);
}

abstract class PagedProviderValue<T> {
  PagedProviderValue();

  PagedProviderFacade<T> of(WidgetRef ref);
}

abstract class CommandProviderValue<T, ArgT extends Record> {
  const CommandProviderValue();

  CommandProviderFacade<T, ArgT> of(WidgetRef ref);
}
