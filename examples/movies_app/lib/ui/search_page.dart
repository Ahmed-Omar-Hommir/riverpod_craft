import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

import '../providers/search_movies_provider.dart';
import '../providers/search_query_provider.dart';
import 'widgets.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.isActive = false});

  final bool isActive;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void didUpdateWidget(SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _focus.requestFocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.searchQueryProvider.watch();
    final state = ref.searchMoviesCommand.watch();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          decoration: const InputDecoration(
            hintText: 'Search movies…',
            border: InputBorder.none,
          ),
          onChanged: (v) {
            ref.searchQueryProvider.setState(v);
            ref.searchMoviesCommand.run(query: v);
          },
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                ref.searchQueryProvider.setState('');
                ref.searchMoviesCommand.reset();
              },
            ),
        ],
      ),
      body: state.when(
        init: () => const PagePlaceholder(
          icon: Icons.search,
          label: 'Search for movies',
        ),
        loading: (_) => const Center(child: CircularProgressIndicator()),
        data: (_, movies) => movies.isEmpty
            ? PagePlaceholder(
                icon: Icons.movie_filter_outlined,
                label: 'No results for "$query"',
              )
            : ListView.builder(
                itemCount: movies.length,
                itemBuilder: (_, i) => MovieTile(movies[i]),
              ),
        error: (_, err) => PagePlaceholder(
          icon: Icons.error_outline,
          label: 'Search failed',
          action: FilledButton.tonal(
            onPressed: () => ref.searchMoviesCommand.run(query: query),
            child: const Text('Retry'),
          ),
        ),
      ),
    );
  }
}
