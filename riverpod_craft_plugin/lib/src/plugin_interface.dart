import 'data_model.dart';

/// The interface every riverpod_craft plugin implements.
///
/// A plugin defines:
/// 1. What annotations it handles (e.g., `['provider']`, `['paginated']`)
/// 2. How to collect data from annotated classes/functions
/// 3. How to generate Dart code from that data
abstract class RiverpodCraftPlugin<T> {
  /// Unique identifier for this plugin (e.g., 'provider', 'command', 'pagination').
  String get id;

  /// The annotation names this plugin handles.
  ///
  /// Used for:
  /// - Fast-path file detection (skip files without these annotations)
  /// - Routing annotated elements to this plugin
  List<String> get annotations;

  /// Called for each annotated element whose annotation matches this plugin.
  ///
  /// Inspect the [element] (a class or function with clean metadata) and
  /// return your plugin's own data object, or `null` to skip this element.
  T? collect(DartElementInfo element);

  /// Generate Dart code from collected data.
  ///
  /// Called once for each non-null result from [collect].
  /// Return the generated Dart code string.
  String generate(T collectedData);

  /// Additional imports the generated file needs.
  ///
  /// Override this to add import statements to the generated `.pg.dart` file.
  List<String> get requiredImports => [];
}

/// Wraps a plugin's collected result with a reference to the plugin.
class PluginCollectionResult {
  const PluginCollectionResult({
    required this.plugin,
    required this.data,
  });

  final RiverpodCraftPlugin plugin;
  final Object data;

  /// Generate code by delegating to the plugin.
  String generate() {
    return (plugin as dynamic).generate(data) as String;
  }
}
