import 'package:analyzer/dart/analysis/results.dart';
import 'package:craft_runner/craft_runner.dart';
import 'package:dart_style/dart_style.dart';

import 'api_generator.dart';
import 'api_scanner.dart';
import 'retrofit_craft_config.dart';

const _header =
    '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
    '// ignore_for_file: directives_ordering,unnecessary_import,library_private_types_in_public_api\n';

class RetrofitCraftBuilder extends CraftBuilderMultiFile {
  RetrofitCraftBuilder(this.config);

  factory RetrofitCraftBuilder.fromConfig(Map<String, Object?> config) =>
      RetrofitCraftBuilder(RetrofitCraftConfig.fromOptions(config));

  final RetrofitCraftConfig config;

  @override
  List<String> get scope => ['lib'];

  @override
  void build(Map<String, ParseStringResult> results) {
    final scanner = ApiScanner()
      ..entryFilePath = config.entryPath
      ..versionFilePath = config.versionPath;

    results.forEach((path, result) {
      if (_isGenerated(path)) return;
      if (!_mayContribute(result.content, path)) return;
      scanner.collectFromUnit(result, path);
    });

    if (scanner.apiClasses.isEmpty) return;

    final generated = generateAppApi(
      config: config,
      entries: scanner.entries,
      versions: scanner.versions,
      apiClasses: scanner.apiClasses,
      outputAbsPath: config.output,
    );

    final source = generated.source;
    if (source == null) {
      for (final diagnostic in generated.diagnostics) {
        // ignore: avoid_print
        print('retrofit_craft: $diagnostic');
      }
      return;
    }

    writeIfChanged(config.output, _format('$_header$source'));
  }

  bool _isGenerated(String path) =>
      path.endsWith('.craft.dart') ||
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart');

  /// Screens a file before the scanner walks its AST.
  bool _mayContribute(String content, String path) {
    if (content.contains('@Api')) return true;

    final scoped = config.entryPath != null && config.versionPath != null;
    if (scoped) return path == config.entryPath || path == config.versionPath;

    return content.contains('enum ') || content.contains('static const');
  }

  String _format(String content) {
    try {
      return DartFormatter(
        languageVersion: DartFormatter.latestLanguageVersion,
      ).format(content);
    } catch (_) {
      return content;
    }
  }
}
