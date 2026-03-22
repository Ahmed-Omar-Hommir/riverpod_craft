import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_craft_plugin/riverpod_craft_plugin.dart';

import 'src/plugin_runner.dart';
import 'src/plugins/provider_plugin.dart';
import 'src/plugins/command_plugin.dart';

/// The default set of built-in plugins.
final List<RiverpodCraftPlugin> builtInPlugins = [
  ProviderPlugin(),
  CommandPlugin(),
];

/// Handles file processing operations
class FileProcessor {
  static final Map<String, String> _fileContentCache = {};
  static final Map<String, DateTime> _fileModificationCache = {};

  /// The plugin runner used for code generation.
  static PluginRunner _pluginRunner = PluginRunner(builtInPlugins);

  /// Register additional plugins (e.g., community plugins from config).
  ///
  /// If an extra plugin has the same [RiverpodCraftPlugin.id] as a built-in,
  /// it **replaces** the built-in plugin instead of running alongside it.
  /// This lets developers extend a built-in plugin and swap it in.
  static void registerPlugins(List<RiverpodCraftPlugin> extraPlugins) {
    final extraIds = extraPlugins.map((p) => p.id).toSet();
    final kept = builtInPlugins.where((p) => !extraIds.contains(p.id)).toList();
    _pluginRunner = PluginRunner([...kept, ...extraPlugins]);
  }

  /// Processes file only if it has changed
  static Future<void> processFileIfChanged(File file) async {
    final filePath = file.path;
    final lastModified = await file.lastModified();

    if (_fileModificationCache[filePath] == lastModified) {
      return; // File hasn't changed
    }

    _fileModificationCache[filePath] = lastModified;

    final contents = await file.readAsString();

    await processProviderFile(contents, file);
  }

  static Future<void> processProviderFile(String contents, File file) async {
    try {
      var effectiveContents = contents;
      if (_fileContentCache[file.path] == effectiveContents) {
        return; // Content hasn't changed
      }

      final fileName = file.uri.pathSegments.last;
      final partName = fileName.replaceAll('.dart', '.pg.dart');
      final generatedFilePath =
          '${file.parent.path.endsWith('/') ? file.parent.path : '${file.parent.path}/'}$partName';
      final generatedFile = File(generatedFilePath);

      // Fast path: if file clearly has no plugin annotations, avoid analyzer parse.
      // The check is driven by the union of all registered plugin annotation names.
      final stripped = effectiveContents
          // Remove block comments
          .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
          // Remove line comments
          .replaceAll(RegExp(r'//.*'), '');

      final allAnnotations = _pluginRunner.allAnnotations;
      final maybeAnnotated = allAnnotations.any(
        (name) => stripped.contains('@$name'),
      );

      if (!maybeAnnotated) {
        final hasPartLine =
            effectiveContents.contains("part '$partName';") ||
            effectiveContents.contains('part "$partName";');
        final generatedExists = await generatedFile.exists();

        if (hasPartLine || generatedExists) {
          await _cleanupPartLineSimple(file, partName);
          if (generatedExists) {
            await generatedFile.delete();
          }
          _fileContentCache[file.path] = await file.readAsString();
        } else {
          _fileContentCache[file.path] = effectiveContents;
        }
        return;
      }

      final parsedResult = parseString(content: effectiveContents);
      final parsedUnit = parsedResult.unit;

      // Run the plugin pipeline
      final generatedContent = _pluginRunner.run(parsedResult);

      if (generatedContent == null || generatedContent.isEmpty) {
        await _cleanupPartAndGenerated(file, parsedUnit);
        _fileContentCache[file.path] = await file.readAsString();
        return;
      }

      effectiveContents = await _ensurePartDirective(
        file,
        effectiveContents,
        parsedUnit,
      );
      _fileContentCache[file.path] = effectiveContents;

      final fullContent = "part of '$fileName';\n\n$generatedContent";

      final formatter = DartFormatter(
        languageVersion: DartFormatter.latestLanguageVersion,
      );

      final formatted = formatter.format(fullContent);
      await File(generatedFilePath).writeAsString(formatted);
    } on FileSystemException catch (e) {
      print('FileSystemException: ${e.message}, path = ${e.path}');
    } catch (e) {
      print('Error processing file "${file.path}": $e');
    }
  }

  static Future<String> _ensurePartDirective(
    File file,
    String contents,
    CompilationUnit unit,
  ) async {
    final fileName = p.basename(file.path);
    final partName = fileName.replaceAll('.dart', '.pg.dart');

    final hasPartDirective = unit.directives.whereType<PartDirective>().any(
      (p) => p.uri.stringValue == partName,
    );
    if (hasPartDirective) {
      // Ensure a blank line before the part directive for formatting consistency
      final lines = contents.split('\n');
      final partIndex = lines.indexWhere(
        (line) => line.trim() == "part '$partName';",
      );
      if (partIndex > 0 && lines[partIndex - 1].trim().isNotEmpty) {
        lines.insert(partIndex, '');
        final updated = lines.join('\n');
        await file.writeAsString(updated);
        return updated;
      }
      return contents;
    }

    // Find insertion point: after last library/import/export/part directive
    int insertOffset = 0;
    if (unit.directives.isNotEmpty) {
      insertOffset = unit.directives.last.end;
    }

    final insertText = "\n\npart '$partName';\n";
    final newContents =
        contents.substring(0, insertOffset) +
        insertText +
        contents.substring(insertOffset);

    await file.writeAsString(newContents);
    return newContents;
  }

  static Future<void> _cleanupPartAndGenerated(
    File file,
    CompilationUnit unit,
  ) async {
    final fileName = p.basename(file.path);
    final partName = fileName.replaceAll('.dart', '.pg.dart');
    final generatedFile = File(p.join(file.parent.path, partName));

    // Delete generated file if it exists
    if (await generatedFile.exists()) {
      await generatedFile.delete();
    }

    // If part directive is present, remove it and rewrite source
    final hasPartDirective = unit.directives.whereType<PartDirective>().any(
      (p) => p.uri.stringValue == partName,
    );
    if (!hasPartDirective) return;

    final lines = await file.readAsLines();
    final filtered = lines.where(
      (line) => !line.trim().startsWith("part '") || !line.contains(partName),
    );
    await file.writeAsString(filtered.join('\n'));
  }

  static Future<void> _cleanupPartLineSimple(File file, String partName) async {
    final lines = await file.readAsLines();
    final filtered = lines.where(
      (line) => !line.trim().startsWith('part ') || (!line.contains(partName)),
    );
    await file.writeAsString(filtered.join('\n'));
  }
}
