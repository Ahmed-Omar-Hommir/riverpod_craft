import 'package:example/providers/mapped_notes_provider.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

part 'typed_error_provider.craft.dart';

// Custom error type
class NameError implements Exception {
  const NameError(this.message);
  final String message;
}

// Provider with typed error
@provider
@ErrorResult(NameError)
Future<String> userName(Ref ref) async {
  throw NameError('User not found');
}

// Usage example
void exampleUsage(WidgetRef ref) {
  // Typed .when() — error is CraftError<NameError>
  ref.userNameProvider.when(
    loading: () {},
    data: (name) {},
    error: (e) => switch (e) {
      Expected(:final error) => error.message, // error is NameError
      Unexpected(:final error) => 'Unexpected: $error',
    },
  );
}
