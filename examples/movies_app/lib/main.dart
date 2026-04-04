import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

import 'exceptions/api_exception.dart';
import 'providers/trending_movies_provider.dart';
import 'ui/invalid_api_key_page.dart';
import 'ui/main_screen.dart';

void main() {
  runApp(const ProviderScope(child: MoviesApp()));
}

class MoviesApp extends ConsumerWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingState = ref.trendingMoviesProvider.watch();

    // If the API key is invalid, show the feedback page instead of the app.
    final isKeyInvalid = trendingState.whenOrNull(
          error: (error) => error is InvalidApiKeyException,
        ) ??
        false;

    return MaterialApp(
      title: 'Movies App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: isKeyInvalid ? const InvalidApiKeyPage() : const MainScreen(),
    );
  }
}
