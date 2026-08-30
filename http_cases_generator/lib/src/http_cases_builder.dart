import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:craft_runner/craft_runner.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

import 'api_cases_config.dart';
import 'api_cases_generator.dart';
import 'api_cases_models.dart';
import 'api_cases_scanner.dart';

const _header = '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
    '// ignore_for_file: directives_ordering\n\n';

class HttpCasesBuilder extends CraftBuilderMultiFile {
  HttpCasesBuilder(this.config);

  factory HttpCasesBuilder.fromConfig(Map<String, Object?> config) =>
      HttpCasesBuilder(ApiCasesConfig.fromOptions(config));

  final ApiCasesConfig config;

  @override
  List<String> get scope => config.scope;

  @override
  void build(Map<String, ParseStringResult> results) {
    if (!config.output.endsWith('.craft.dart')) {
      throw const ApiCasesGenerationError([
        'The configured output must end with .craft.dart.',
      ]);
    }

    final scanner = ApiCasesScanner();
    final partOwners = _partOwners(results);
    for (final entry in results.entries) {
      final path = entry.key;
      if (_isGenerated(path)) continue;

      final partOfDirectives =
          entry.value.unit.directives.whereType<PartOfDirective>().toList();
      final isPart = partOfDirectives.isNotEmpty;
      final owner = partOwners[path];
      if (isPart && owner == null) {
        final location = entry.value.lineInfo.getLocation(
          partOfDirectives.first.offset,
        );
        scanner.addDiagnostic(
          '$path:${location.lineNumber}:${location.columnNumber}: contains '
          '@ApiCase declarations and is a part, but its '
          'owning library was not found in the configured scope.',
        );
      }
      scanner.collectFromUnit(
        entry.value,
        path,
        importPath: owner ?? path,
      );
    }

    final scan = scanner.result;
    final generated = generateApiCases(
      cases: scan.cases,
      outputPath: config.output,
      initialDiagnostics: scan.diagnostics,
    );
    if (!generated.success) {
      throw ApiCasesGenerationError(generated.diagnostics);
    }

    writeIfChanged(config.output, _format('$_header${generated.source}'));
  }

  Map<String, String> _partOwners(Map<String, ParseStringResult> results) {
    final owners = <String, String>{};
    for (final entry in results.entries) {
      for (final directive in entry.value.unit.directives) {
        if (directive is! PartDirective) continue;
        final uri = directive.uri.stringValue;
        if (uri == null ||
            uri.startsWith('package:') ||
            uri.startsWith('dart:')) {
          continue;
        }
        final partPath = p
            .normalize(p.join(p.dirname(entry.key), uri))
            .replaceAll(r'\', '/');
        owners[partPath] = entry.key;
      }
    }
    return owners;
  }

  bool _isGenerated(String path) =>
      path.endsWith('.craft.dart') ||
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart');

  String _format(String source) => DartFormatter(
        languageVersion: DartFormatter.latestLanguageVersion,
      ).format(source);
}
