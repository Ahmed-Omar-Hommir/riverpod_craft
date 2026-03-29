import 'package:riverpod_craft/riverpod_craft.dart';

part 'x_provider.craft.dart';

@provider
@ErrorResult(MyNameException)
Future<String> name(Ref ref) async {
  return 'Ahmed';
}

void ui(Ref ref) {
  ref.nameProvider.listen((p, n) {
    n.when(loading: () {}, data: (name) {}, error: (e) {});
  });
}

class ErrorResult {
  const ErrorResult(Type type);
}

abstract class CraftException<T> {
  const CraftException();
}

class CustomException<T> extends CraftException<T> {}

class Unxpected<T> extends CraftException<T> {
  const Unxpected(this.error);

  final Object error;
}

class MyNameException implements CraftException<String> {}
