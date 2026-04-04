import '../config.dart';

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;

  String? get posterUrl =>
      posterPath != null ? '$imageBaseUrl/w342$posterPath' : null;

  String? get backdropUrl =>
      backdropPath != null ? '$imageBaseUrl/w780$backdropPath' : null;

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String? ?? '',
      genreIds:
          (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }
}

class Genre {
  const Genre({required this.id, required this.name});

  final int id;
  final String name;

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'] as int, name: json['name'] as String);
  }
}

const defaultGenres = [
  Genre(id: 28, name: 'Action'),
  Genre(id: 35, name: 'Comedy'),
  Genre(id: 18, name: 'Drama'),
  Genre(id: 27, name: 'Horror'),
  Genre(id: 878, name: 'Sci-Fi'),
  Genre(id: 10749, name: 'Romance'),
];
