import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

import 'providers/countries_provider.dart';
import 'async_dropdown.dart';
import 'async_paged_dropdown.dart';
import 'sync_dropdown.dart';

class DropdownPage extends ConsumerWidget {
  const DropdownPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reusable Components'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ProviderValue (Synchronous)',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Displays items from any synchronous provider.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SyncDropdown<String>(
              providerValue: ref.featuredCountryProvider,
              label: 'Featured Country',
              hint: const Text('Select a country'),
              itemBuilder: (context, data, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(data),
              ),
              selectedLabelBuilder: (item) => Text(item),
              onChanged: (value) {},
            ),
            const SizedBox(height: 32),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 32),
            Text(
              'DataProviderValue (Async)',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Loads all countries at once from the provider.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            AsyncDropdown<String>(
              providerValue: ref.countriesProvider,
              label: 'Country',
              hint: const Text('Select a country'),
              itemBuilder: (context, data, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(data),
              ),
              selectedLabelBuilder: (item) => Text(item),
              onChanged: (value) {},
            ),
            const SizedBox(height: 32),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 32),
            Text(
              'PagedProviderValue (Paginated)',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Supports infinite scrolling and pull-to-refresh.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            AsyncPagedDropdown<String>(
              providerValue: ref.countriesPagedProvider,
              label: 'Country (Paged)',
              hint: const Text('Select a country'),
              itemBuilder: (context, data, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(data),
              ),
              selectedLabelBuilder: (item) => Text(item),
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}
