import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'movie_detail_page.dart';

// ── Movie Poster ──────────────────────────────────────────────────────────────

class MoviePoster extends StatelessWidget {
  const MoviePoster(this.url, {super.key, this.width, this.height});

  final String? url;
  final double? width, height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: url != null
            ? Image.network(
                url!,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(context),
              )
            : _placeholder(context),
      );

  Widget _placeholder(BuildContext context) => Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.movie_outlined, color: Colors.white38),
      );
}

// ── Star Chip (★ 7.8) ─────────────────────────────────────────────────────────

class StarChip extends StatelessWidget {
  const StarChip(this.score, {super.key});

  final double score;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
            const SizedBox(width: 2),
            Text(
              score.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),
        ),
      );
}

// ── Movie List Tile ───────────────────────────────────────────────────────────

/// Shared tile used in search results and paginated list.
class MovieTile extends StatelessWidget {
  const MovieTile(this.movie, {super.key});

  final Movie movie;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: MoviePoster(movie.posterUrl, width: 48, height: 72),
        title: Text(
          movie.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(children: [
          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(movie.voteAverage.toStringAsFixed(1)),
          if (movie.releaseDate.length >= 4) ...[
            const SizedBox(width: 8),
            Text(
              movie.releaseDate.substring(0, 4),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ]),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(movieId: movie.id),
          ),
        ),
      );
}

// ── Empty / Error Placeholder ─────────────────────────────────────────────────

class PagePlaceholder extends StatelessWidget {
  const PagePlaceholder({
    super.key,
    required this.icon,
    required this.label,
    this.action,
  });

  final IconData icon;
  final String label;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ]),
      );
}
