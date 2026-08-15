import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// The resolved `riverpod_craft` configuration for one build: the mapper
/// functions already parsed down to the facts the generator needs.
///
/// Immutable and passed explicitly down the generation path. build_runner runs
/// build steps concurrently, so configuration must never live in mutable
/// globals where one step can change what another is reading.
class RiverpodCraftOptions {
  const RiverpodCraftOptions({
    this.errorMapperPath,
    this.errorMapperSource,
    this.errorMapperOutputType,
    this.pagedMapperPath,
    this.pagedMapperSource,
    this.pagedMapperInputType,
  });

  static const empty = RiverpodCraftOptions();

  /// Private name the user's `errorMapper` is inlined under in each generated
  /// part. The leading `_` keeps it library-private so barrel re-exports can't
  /// produce an ambiguous export.
  static const errorMapperInlineName = r'_$errorMapper';

  bool get hasErrorMapper => errorMapperSource != null;

  bool get hasPagedMapper => pagedMapperInputType != null;

  /// The error type parameter `F` in generated code: the mapper's return type
  /// when one is configured, otherwise `Object`.
  String get errorType => errorMapperOutputType ?? 'Object';

  final String? errorMapperPath;

  /// The `errorMapper` function source, already renamed to
  /// [RiverpodCraftOptions.errorMapperInlineName].
  final String? errorMapperSource;

  /// The mapper's return type — becomes the error type parameter `F`.
  final String? errorMapperOutputType;

  final String? pagedMapperPath;
  final String? pagedMapperSource;

  /// The mapper's first parameter type, minus generics.
  final String? pagedMapperInputType;

  /// Parses both mapper sources. Pure — no filesystem, no globals — so the
  /// caller can cache the result by source content.
  static RiverpodCraftOptions resolve({
    String? errorMapperPath,
    String? errorMapperContent,
    String? pagedMapperPath,
    String? pagedMapperContent,
  }) {
    final error = errorMapperContent == null
        ? null
        : _findFunction(errorMapperContent, 'errorMapper');
    final paged = pagedMapperContent == null
        ? null
        : _findFunction(pagedMapperContent, 'pagedMapper');

    // The paths are only carried when the function was actually found.
    // `hasErrorMapper`/`hasPagedMapper` key off them, and a path without a
    // resolved function would make the generator emit calls to a mapper whose
    // definition never gets inlined.
    return RiverpodCraftOptions(
      errorMapperPath: error == null ? null : errorMapperPath,
      errorMapperSource: error?.toSource().replaceFirst(
        'errorMapper',
        RiverpodCraftOptions.errorMapperInlineName,
      ),
      errorMapperOutputType: error?.returnType?.toSource(),
      pagedMapperPath: paged == null ? null : pagedMapperPath,
      pagedMapperSource: paged?.toSource(),
      pagedMapperInputType: _firstParamType(paged),
    );
  }

  static FunctionDeclaration? _findFunction(String content, String name) {
    final unit = parseString(
      content: content,
      throwIfDiagnostics: false,
    ).unit;
    for (final declaration in unit.declarations) {
      if (declaration is FunctionDeclaration &&
          declaration.name.lexeme == name) {
        return declaration;
      }
    }
    return null;
  }

  /// `PaginatedResponse<T> pagedMapper<T>(ApiPagedResponse<T> d)` →
  /// `ApiPagedResponse`.
  static String? _firstParamType(FunctionDeclaration? function) {
    final params = function?.functionExpression.parameters?.parameters;
    if (params == null || params.isEmpty) return null;
    final type = params.first.type?.toSource();
    if (type == null) return null;
    final generic = type.indexOf('<');
    return generic > 0 ? type.substring(0, generic) : type;
  }
}
