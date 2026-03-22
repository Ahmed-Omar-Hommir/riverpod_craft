import 'package:analyzer/dart/analysis/results.dart' show ParseStringResult;
import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';
import 'package:riverpod_craft_cli/provider_info.dart';

import 'ast_to_model.dart';

/// Orchestrates the plugin pipeline:
/// 1. Convert AST -> clean data model
/// 2. For each element, find matching plugins -> call collect()
/// 3. Call generate() on each collected result
/// 4. Return combined generated code
class PluginRunner {
  const PluginRunner(this.plugins);

  final List<RiverpodCraftPlugin> plugins;

  /// The union of all annotation names across all registered plugins.
  ///
  /// Used for the fast-path check: if a file contains none of these,
  /// skip full AST parsing.
  Set<String> get allAnnotations =>
      plugins.expand((p) => p.annotations).toSet();

  /// Run the full pipeline on a parsed file.
  ///
  /// Returns the generated code string, or `null` if nothing was generated.
  String? run(ParseStringResult parsedResult) {
    final elements = astToModel(parsedResult);

    final results = <PluginCollectionResult>[];

    for (final element in elements) {
      for (final plugin in plugins) {
        final hasMatch = element.annotations.any(
          (a) => plugin.annotations.contains(a.name),
        );
        if (!hasMatch) continue;

        final data = plugin.collect(element);
        if (data != null) {
          results.add(PluginCollectionResult(plugin: plugin, data: data));
        }
      }
    }

    if (results.isEmpty) return null;

    // Enrich ProviderInfo with the list of all provider variable names
    // (needed by ProviderCodeGenerator for the `refs` getter).
    _enrichProviderData(results);

    final generated = results.map((r) => r.generate()).join('\n');
    return generated;
  }

  /// Replaces each collected [ProviderInfo] with an enriched copy that
  /// includes all provider variable names from this file.
  void _enrichProviderData(List<PluginCollectionResult> results) {
    final providerResults = <int>[];
    final allVarNames = <String>[];

    for (var i = 0; i < results.length; i++) {
      if (results[i].data is ProviderInfo) {
        providerResults.add(i);
        allVarNames.add((results[i].data as ProviderInfo).providerVarName);
      }
    }

    if (providerResults.isEmpty) return;

    for (final idx in providerResults) {
      final info = results[idx].data as ProviderInfo;
      final enriched = ProviderInfo(
        name: info.name,
        dataType: info.dataType,
        isKeepAlive: info.isKeepAlive,
        type: info.type,
        params: info.params,
        commands: info.commands,
        isFunctional: info.isFunctional,
        functionName: info.functionName,
        requiresRef: info.requiresRef,
        isSettable: info.isSettable,
        allProviderVarNames: allVarNames,
        publicMethods: info.publicMethods,
      );
      results[idx] = PluginCollectionResult(
        plugin: results[idx].plugin,
        data: enriched,
      );
    }
  }
}
