import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

import '../providers/guest_ratings_provider.dart';
import '../providers/movie_detail_provider.dart';
import '../providers/trending_movies_provider.dart';
import 'widgets.dart';

class MovieDetailPage extends ConsumerStatefulWidget {
  const MovieDetailPage({super.key, required this.movieId});

  final int movieId;

  @override
  ConsumerState<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends ConsumerState<MovieDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ref.movieDetailProvider(id: widget.movieId).watch().when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_) => PagePlaceholder(
              icon: Icons.error_outline,
              label: 'Failed to load movie',
              action: FilledButton.tonal(
                onPressed: () =>
                    ref.movieDetailProvider(id: widget.movieId).reload(),
                child: const Text('Retry'),
              ),
            ),
            data: (movie) => CustomScrollView(slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(movie.title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    background: movie.backdropUrl != null
                        ? Image.network(
                            movie.backdropUrl!,
                            fit: BoxFit.cover,
                            color: Colors.black38,
                            colorBlendMode: BlendMode.darken,
                          )
                        : null,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.list(children: [
                    // Info row
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(movie.voteAverage.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.titleSmall),
                      if (movie.releaseDate.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text(movie.releaseDate,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ]),
                    const SizedBox(height: 16),

                    // Overview
                    Text('Overview',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(movie.overview,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 24),

                    // Rating
                    Text('Your Rating',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _RatingSection(movieId: movie.id),
                  ]),
                ),
              ]),
          ),
    );
  }
}

void _snack(BuildContext ctx, String msg) =>
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));

// ── Rating Section ────────────────────────────────────────────────────────────

class _RatingSection extends ConsumerStatefulWidget {
  const _RatingSection({required this.movieId});

  final int movieId;

  @override
  ConsumerState<_RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends ConsumerState<_RatingSection> {
  double _stars = 5.0;
  bool _picked = false;
  double? _optimisticRating;

  @override
  Widget build(BuildContext context) {
    final ratingsState = ref.guestRatingsProvider.watch();
    final cmdState = ref.trendingMoviesProvider.rateMovieCommand.watch();
    final apiRating = ratingsState.dataOrNull?[widget.movieId];

    // Once TMDB confirms the rating, clear the optimistic value
    if (apiRating != null && _optimisticRating != null) {
      _optimisticRating = null;
    }

    final displayRating = apiRating ?? _optimisticRating;

    if (apiRating != null && !_picked) _stars = apiRating;

    ref.trendingMoviesProvider.rateMovieCommand.listen((_, next) {
      next.whenOrNull(
        data: (_, rating) {
          setState(() => _optimisticRating = rating);
          ref.guestRatingsProvider.silentReload();
          _snack(context, 'Rated ${rating.toStringAsFixed(1)} ⭐');
        },
        error: (_, err) => _snack(context, 'Rating failed: $err'),
      );
    });

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Status badge
      _RatingBadge(isLoading: ratingsState.isLoading && displayRating == null, savedRating: displayRating),
      const SizedBox(height: 8),

      // Stars + submit
      Row(children: [
        ...List.generate(5, (i) {
          final value = (i + 1) * 2.0;
          return IconButton(
            icon: Icon(
              _stars >= value
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: Colors.amber,
              size: 32,
            ),
            onPressed: cmdState.isLoading
                ? null
                : () => setState(() {
                      _stars = value;
                      _picked = true;
                    }),
          );
        }),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: cmdState.isLoading
              ? null
              : () => ref.trendingMoviesProvider.rateMovieCommand.run(
                    movieId: widget.movieId,
                    rating: _stars,
                  ),
          child: cmdState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(displayRating != null ? 'Update' : 'Submit'),
        ),
      ]),
    ]);
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.isLoading, required this.savedRating});

  final bool isLoading;
  final double? savedRating;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isLoading) {
      return Row(children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
        ),
        const SizedBox(width: 8),
        Text('Loading your rating…',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
      ]);
    }

    if (savedRating != null) {
      return Row(children: [
        Icon(Icons.check_circle_rounded, size: 16, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          'You rated this ${savedRating!.toStringAsFixed(1)}/10',
          style: TextStyle(
              color: cs.primary, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ]);
    }

    return const SizedBox.shrink();
  }
}
