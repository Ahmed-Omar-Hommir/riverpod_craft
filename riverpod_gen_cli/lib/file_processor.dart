import 'dart:io';

import 'package:riverpod_gen_cli/collect_data.dart';
import 'package:riverpod_gen_cli/provider_generated_file.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

/// Handles file processing operations
class FileProcessor {
  static final Map<String, String> _fileContentCache = {};
  static final Map<String, DateTime> _fileModificationCache = {};

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

      // Fast path: if file clearly has no provider annotations, avoid analyzer parse.
      // Strip comments before checking to avoid false positives from commented code.
      final stripped = effectiveContents
          // Remove block comments
          .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
          // Remove line comments
          .replaceAll(RegExp(r'//.*'), '');

      final maybeAnnotated =
          stripped.contains('@provider') ||
          stripped.contains('@providerValue') ||
          stripped.contains('@command') ||
          stripped.contains('@Command');

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

      final providerDataCollection = collectData(parsedResult);

      String generatedContent = '';

      final hasProvidersOrCommands =
          providerDataCollection.providers.isNotEmpty ||
          providerDataCollection.commands.isNotEmpty;

      generatedContent +=
          ProviderGeneratedFile(
            file: file,
            providerDataCollection: providerDataCollection,
          ).build() ??
          '';

      if (!hasProvidersOrCommands) {
        await _cleanupPartAndGenerated(file, parsedUnit);
        _fileContentCache[file.path] = await file.readAsString();
        return; // No providers/commands -> clean part + generated and exit
      }

      if (generatedContent.isEmpty) {
        // Defensive: nothing generated, still ensure cleanup
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

      generatedContent = "part of '$fileName';\n\n$generatedContent";

      final formatter = DartFormatter(
        languageVersion: DartFormatter.latestLanguageVersion,
      );

      final formatted = formatter.format(generatedContent);
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
