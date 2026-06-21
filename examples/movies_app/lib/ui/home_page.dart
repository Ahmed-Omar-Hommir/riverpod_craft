import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

import '../models/movie.dart';
import '../providers/now_playing_provider.dart';
import '../providers/trending_movies_provider.dart';
import 'movie_detail_page.dart';
import 'widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movies')),
      body: RefreshIndicator(
        onRefresh: () => ref.trendingMoviesProvider.reload(),
        child: ListView(children: [
          _SectionHeader('Now Playing', live: true),
          _NowPlayingCarousel(ref.nowPlayingProvider.watch()),
          const SizedBox(height: 8),
          _SectionHeader('Trending This Week'),
          _TrendingGrid(ref.trendingMoviesProvider.watch()),
        ]),
      ),
    );
  }
}

// ── helpers ───────────────────────────────────────────────────────────────────

void _push(BuildContext ctx, Widget page) =>
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => page));

// ── section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.live = false});

  final String title;
  final bool live;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (live) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            const Text(
              'LIVE',
              style: TextStyle(
                  color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ]),
      );
}

// ── now playing carousel ──────────────────────────────────────────────────────

class _NowPlayingCarousel extends StatelessWidget {
  const _NowPlayingCarousel(this.state);

  final DataState<List<Movie>, Object> state;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 190,
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_) => const Center(child: Text('Failed to load')),
          data: (movies) => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: movies.length.clamp(0, 10),
            itemBuilder: (_, i) => _NowPlayingCard(movies[i]),
          ),
        ),
      );
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard(this.movie);

  final Movie movie;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _push(context, MovieDetailPage(movieId: movie.id)),
        child: Container(
          width: 120,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(children: [
            Expanded(child: MoviePoster(movie.posterUrl, width: 120)),
            const SizedBox(height: 4),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ]),
        ),
      );
}

// ── trending grid ─────────────────────────────────────────────────────────────

class _TrendingGrid extends StatelessWidget {
  const _TrendingGrid(this.state);

  final DataState<List<Movie>, Object> state;

  @override
  Widget build(BuildContext context) => state.when(
        loading: () => const SizedBox(
            height: 200, child: Center(child: CircularProgressIndicator())),
        error: (_) => PagePlaceholder(
          icon: Icons.error_outline,
          label: 'Failed to load trending movies',
        ),
        data: (movies) => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: movies.length.clamp(0, 12),
          itemBuilder: (_, i) => _GridTile(movies[i]),
        ),
      );
}

class _GridTile extends StatelessWidget {
  const _GridTile(this.movie);

  final Movie movie;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _push(context, MovieDetailPage(movieId: movie.id)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              MoviePoster(movie.posterUrl),
              Positioned(
                  bottom: 4, right: 4, child: StarChip(movie.voteAverage)),
            ]),
          ),
          const SizedBox(height: 4),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ]),
      );
}
