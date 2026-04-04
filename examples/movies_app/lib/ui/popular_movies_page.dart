import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

import '../models/movie.dart';
import '../providers/popular_movies_provider.dart';
import 'widgets.dart';

class PopularMoviesPage extends ConsumerWidget {
  const PopularMoviesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: defaultGenres.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Popular Movies'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: 'All'),
              ...defaultGenres.map((g) => Tab(text: g.name)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _Tab(genreId: null),
            ...defaultGenres.map((g) => _Tab(genreId: g.id)),
          ],
        ),
      ),
    );
  }
}

class _Tab extends ConsumerWidget {
  const _Tab({required this.genreId});

  final int? genreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => CraftPagedListView<Movie>(
        provider: ref.popularMoviesProvider(genreId: genreId),
        itemBuilder: (_, movie, __) => MovieTile(movie),
        emptyBuilder: (_) => const PagePlaceholder(
          icon: Icons.movie_filter_outlined,
          label: 'No movies found',
        ),
        firstPageLoadingBuilder: (_) =>
            const Center(child: CircularProgressIndicator()),
      );
}
