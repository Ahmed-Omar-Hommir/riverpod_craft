# riverpod_craft_plugin

Plugin interface and data models for [riverpod_craft](https://pub.dev/packages/riverpod_craft) code generation plugins.

## Usage

Implement `RiverpodCraftPlugin<T>` to create a custom code generation plugin:

```dart
import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';

class MyPlugin extends RiverpodCraftPlugin<MyData> {
  @override
  String get id => 'my_plugin';

  @override
  List<String> get annotations => ['myAnnotation'];

  @override
  MyData? collect(DartElementInfo element) {
    // Extract data from annotated classes/functions
  }

  @override
  String generate(MyData data) {
    // Return generated Dart code
  }
}
```

See the [riverpod_craft documentation](https://ahmed-omar-hommir.github.io/riverpod_craft/) for details.
