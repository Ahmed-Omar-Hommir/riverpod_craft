import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

/// A reusable display widget for any synchronous [ProviderValue<T>].
class ValueDisplay<T> extends ConsumerWidget {
  const ValueDisplay({
    super.key,
    required this.providerValue,
    required this.valueBuilder,
    this.label,
  });

  // providerValue is an accessor for the provider, not the actual provider.
  final ProviderValue<T> providerValue;
  final Widget Function(BuildContext context, T value) valueBuilder;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use .of(ref) to access the actual provider in this widget.
    final provider = providerValue.of(ref);
    final value = provider.watch();
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      child: valueBuilder(context, value),
    );
  }
}
