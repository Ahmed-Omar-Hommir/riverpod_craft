---
sidebar_position: 5
---

# Movies App

A real-world app that hits the TMDB API — trending movies, now-playing stream, paginated discovery, search with debounce, and guest ratings.

**What you'll learn:**
- `@provider` with `Stream<T>` for live-updating data
- `Paged<T>` for infinite-scroll pagination
- `@command @droppable` for rating operations
- `@command @restartable` for search with debounce
- Parametrized providers with optional parameters
- `@settable` for UI filter state

[Source code](https://github.com/Ahmed-Omar-Hommir/riverpod_craft/tree/master/examples/movies_app)

:::info
This example requires a [TMDB API key](https://developer.themoviedb.org/docs/getting-started). Add it to `lib/config.dart` before running.
:::

---

## Providers

### Trending movies — class with command

Fetches the weekly trending list. The `rateMovie` command is `@droppable` — tapping the rate button twice won't send duplicate requests:

```dart
@provider
class TrendingMovies extends _$TrendingMovies {
  @override
  Future<List<Movie>> create() async {
    final guestSessionId = await GuestSessionService.instance.getId();
    final response = await dio.get(
      '/trending/movie/week',
      queryParameters: {'guest_session_id': guestSessionId},
    );
    validateResponse(response);
    return (response.data['results'] as List)
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  @command
  @droppable
  Future<double> rateMovie({
    required int movieId,
    required double rating,
  }) async {
    final guestSessionId = await GuestSessionService.instance.getId();
    final res = await dio.post(
      '/movie/$movieId/rating',
      queryParameters: {'guest_session_id': guestSessionId},
      data: {'value': rating},
    );
    if (res.statusCode == 401) {
      await GuestSessionService.instance.clear();
      throw Exception('Guest session expired. Please try again.');
    }
    return rating;
  }
}
```

### Now playing — `Stream` provider

Polls the API every 30 seconds using `async*`. The UI rebuilds each time new data arrives:

```dart
@provider
Stream<List<Movie>> nowPlaying(Ref ref) async* {
  while (true) {
    final response = await dio.get('/movie/now_playing');
    validateResponse(response);
    yield (response.data['results'] as List)
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
    await Future.delayed(const Duration(seconds: 30));
  }
}
```

### Popular movies — `Paged<T>` pagination

Return `Paged<T>` from `create()` to get automatic infinite-scroll support. The `page` parameter and `PaginatedResponse` metadata are handled by the framework:

```dart
@provider
class PopularMovies extends _$PopularMovies {
  @override
  Paged<Movie> create(int page, {required int? genreId}) async {
    final response = await dio.get(
      '/discover/movie',
      queryParameters: {
        'page': page,
        'sort_by': 'popularity.desc',
        if (genreId != null) 'with_genres': genreId,
      },
    );
    validateResponse(response);
    final data = response.data;
    return PaginatedResponse(
      results: (data['results'] as List)
          .map((e) => Movie.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: data['page'] as int,
      total: data['total_results'] as int,
      lastPage: data['total_pages'] as int,
      pageSize: 20,
    );
  }
}
```

### Search movies — `@restartable` with debounce

`@restartable` cancels the previous search when a new one starts. The 500ms delay acts as a debounce — if the user types another character before the delay ends, the old request is cancelled:

```dart
@command
@restartable
Future<List<Movie>> searchMovies(Ref ref, {required String query}) async {
  await Future.delayed(const Duration(milliseconds: 500));
  final response = await dio.get(
    '/search/movie',
    queryParameters: {'query': query},
  );
  validateResponse(response);
  return (response.data['results'] as List)
      .map((e) => Movie.fromJson(e as Map<String, dynamic>))
      .toList();
}
```

### Movie detail — family provider

```dart
@provider
Future<Movie> movieDetail(Ref ref, {required int id}) async {
  final response = await dio.get('/movie/$id');
  validateResponse(response);
  return Movie.fromJson(response.data);
}
```

### Guest ratings

```dart
@provider
Future<Map<int, double>> guestRatings(Ref ref) async {
  final sessionId = await GuestSessionService.instance.getStoredId();
  if (sessionId == null) return {};

  final response = await dio.get('/guest_session/$sessionId/rated/movies');
  validateResponse(response);

  return {
    for (final movie in response.data['results'] as List)
      (movie['id'] as int): (movie['rating'] as num).toDouble(),
  };
}
```

### Settable filters

```dart
@provider
@settable
String searchQuery(Ref ref) => '';

@provider
@settable
int? selectedGenre(Ref ref) => null;
```

---

## Key patterns

### Restartable search with debounce

The combination of `@restartable` + `Future.delayed` gives you search debounce for free. Each keystroke cancels the previous delay, so only the final query hits the API:

```dart
// In the search page
onChanged: (query) {
  ref.searchQueryProvider.setState(query);
  if (query.isNotEmpty) {
    ref.searchMoviesCommand.run(query: query);
  }
},
```

### Pagination

The `Paged<T>` return type generates a provider that tracks pages, loading state, and whether more data is available:

```dart
final moviesState = ref.popularMoviesProvider(genreId: selectedGenre).watch();
```

### Rating with feedback

```dart
ref.trendingMoviesProvider.rateMovieCommand.listen((_, next) {
  next.whenOrNull(
    data: (_, __) => showSnackBar('Rating submitted'),
    error: (_, err) => showSnackBar('Failed: $err'),
  );
});
```
