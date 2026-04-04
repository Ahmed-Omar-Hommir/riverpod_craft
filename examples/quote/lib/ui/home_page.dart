import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

import '../models/quote.dart';
import '../providers/favorite_quotes_provider.dart';
import '../providers/random_quote_provider.dart';
import '../providers/save_quote_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final quoteState = ref.randomQuoteProvider.watch();
    final favorites = ref.favoriteQuotesProvider.watch();

    ref.saveQuoteCommand.listen((_, next) {
      next.whenOrNull(
        data: (_, __) => _snack(context, 'Quote saved!'),
        error: (_, err) => _snack(context, 'Failed to save: $err'),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Quote')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _QuoteCard(quoteState: quoteState),
          const SizedBox(height: 16),
          if (favorites.isNotEmpty) _FavoritesList(favorites: favorites),
        ],
      ),
    );
  }
}

void _snack(BuildContext ctx, String msg) =>
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));

// ── Quote Card ────────────────────────────────────────────────────────────────

class _QuoteCard extends ConsumerWidget {
  const _QuoteCard({required this.quoteState});

  final DataState<Quote> quoteState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Random Quote', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            quoteState.when(
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
              data: (quote) {
                final isFav = ref.favoriteQuotesProvider.isFavorite(quote.id);
                return Column(
                  children: [
                    Text(
                      '"${quote.text}"',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '— ${quote.author}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: () =>
                              ref.randomQuoteProvider.invalidate(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('New Quote'),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filled(
                          onPressed: isFav
                              ? null
                              : () {
                                  ref.favoriteQuotesProvider.addQuote(quote);
                                  ref.saveQuoteCommand
                                      .run(quoteId: quote.id);
                                },
                          icon: Icon(isFav
                              ? Icons.favorite
                              : Icons.favorite_border),
                        ),
                      ],
                    ),
                  ],
                );
              },
              error: (_) => Column(
                children: [
                  Text('Failed to load quote',
                      style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => ref.randomQuoteProvider.invalidate(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Favorites List ────────────────────────────────────────────────────────────

class _FavoritesList extends ConsumerWidget {
  const _FavoritesList({required this.favorites});

  final List<Quote> favorites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Favorites (${favorites.length})',
              style: theme.textTheme.titleMedium),
        ),
        ...favorites.map(
          (quote) => Card(
            child: ListTile(
              title: Text(quote.text,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(quote.author),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () =>
                    ref.favoriteQuotesProvider.removeQuote(quote),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
