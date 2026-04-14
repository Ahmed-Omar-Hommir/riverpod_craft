import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

part 'example_provider.craft.dart';

class MyDropDownMenu<StateT> extends ConsumerWidget {
  const MyDropDownMenu({super.key, this.provider});

  final ProviderValue<StateT>? provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (provider == null) return Text("Normal dropdown menu");

    final prov = provider!.of(ref);

    prov.read();

    return const Placeholder();
  }
}

void ui(WidgetRef ref) {
  MyDropDownMenu(provider: ref.namesProvider);
}

@provider
List<String> names(Ref ref) {
  return [];
}
