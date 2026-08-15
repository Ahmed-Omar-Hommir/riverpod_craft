# riverpod_craft_plugin

The code generator for [riverpod_craft](https://pub.dev/packages/riverpod_craft),
plus the plugin interface and data models it is built from.

It runs as a [`craft_runner`](https://pub.dev/packages/craft_runner) builder and
turns `@provider`, `@command` and `@settable` annotations into a `.craft.dart`
part next to each `*_provider.dart` source.

## Usage

Declare it in `craft_runner.yaml`:

```yaml
roots: [lib]

builders:
  riverpod_craft_plugin:RiverpodCraftBuilder:
    error_mapper: lib/error_mapper.dart
    paged_provider_mapper: lib/paged_mapper.dart
```

Both options are optional. `error_mapper` points at a top-level function whose
return type becomes the generated error type; `paged_provider_mapper` adapts
your API's page shape to `PaginatedResponse`. Each is inlined into the generated
files under a private name.

Then run `craft_runner craft`, or `craft_runner watch` to regenerate on save.

Two rules the builder enforces:

- The source file must be named `*_provider.dart`, or it is skipped.
- It must already declare `part '<name>.craft.dart';`. The builder does not edit
  your source — it throws, naming the line to add.

## Extending the generator

`RiverpodCraftPlugin<T>` is the seam the built-in provider and command
generators are written against:

```dart
import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';

class MyPlugin extends RiverpodCraftPlugin<MyData> {
  @override
  String get id => 'my_plugin';

  @override
  List<String> get annotations => ['myAnnotation'];

  @override
  MyData? collect(DartElementInfo element, RiverpodCraftOptions options) {
    // Inspect the annotated class or function; return null to skip it.
  }

  @override
  String generate(MyData data) {
    // Return the generated Dart code.
  }

  @override
  List<String> get requiredImports => const [];
}
```

To generate something that isn't a riverpod provider, write a `CraftBuilder`
against craft_runner directly instead — see its README.

See the [riverpod_craft documentation](https://ahmed-omar-hommir.github.io/riverpod_craft/)
for details.
