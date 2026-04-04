import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InvalidApiKeyPage extends StatelessWidget {
  const InvalidApiKeyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Icon
              CircleAvatar(
                radius: 48,
                backgroundColor: cs.errorContainer,
                child: Icon(Icons.key_off_rounded,
                    size: 48, color: cs.onErrorContainer),
              ),
              const SizedBox(height: 24),

              // Title
              Text('Invalid API Key',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Your TMDB API key is missing, invalid, or expired.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Steps card
              Card(
                color: cs.surfaceContainerHighest,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('How to fix',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _Step(1, 'Get a free API key at',
                            'themoviedb.org/settings/api'),
                        const SizedBox(height: 10),
                        _Step(2, 'Open', 'lib/config.dart'),
                        const SizedBox(height: 10),
                        _Step(3, 'Replace the value of', 'tmdbApiKey'),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Text(
                            "const tmdbApiKey = 'YOUR_KEY_HERE';",
                            style: TextStyle(
                                fontFamily: 'monospace',
                                color: cs.primary,
                                fontSize: 13),
                          ),
                        ),
                      ]),
                ),
              ),
              const SizedBox(height: 16),
              Text('Tap any link below to copy it.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.text, this.link);

  final int number;
  final String text;
  final String link;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(
        radius: 12,
        backgroundColor: cs.primary,
        child: Text('$number',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: cs.onPrimary)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Wrap(spacing: 4, children: [
            Text(text, style: Theme.of(context).textTheme.bodyMedium),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: link));
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied "$link"'),
                        duration: const Duration(seconds: 2)));
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(link,
                    style: TextStyle(
                        fontFamily: 'monospace',
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}
