import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

/// Return types of a library's providers, resolved through the element model
/// and rendered back to source-like strings.
///
/// The generator classifies providers by matching the *text* of the return
/// type (`Future<`, `Stream<`, `Paged<`, …). That reads whatever the developer
/// typed, so a type alias defeats it:
///
/// ```dart
/// typedef Cities = Future<List<CityQueryModel>>;
///
/// @provider
/// Cities cities(Ref ref) => ...;   // reads as `Cities` → sync, data `Cities`
/// ```
///
/// Resolving turns that back into `Future<List<CityQueryModel>>` before the
/// classifier sees it, so the provider is recognised as a future over
/// `List<CityQueryModel>` however it was spelled.
class ResolvedReturnTypes {
  const ResolvedReturnTypes(this._functions, this._methods);

  const ResolvedReturnTypes.empty() : _functions = const {}, _methods = const {};

  final Map<String, String> _functions;

  /// Keyed `ClassName.methodName`.
  final Map<String, String> _methods;

  String? forFunction(String name) => _functions[name];

  String? forMethod(String className, String methodName) =>
      _methods['$className.$methodName'];

  /// Reads every top-level function and class method the generator might care
  /// about. Cheap: the element model is already built by the time a builder
  /// asks for it.
  static ResolvedReturnTypes of(LibraryElement library) {
    final functions = <String, String>{};
    for (final function in library.topLevelFunctions) {
      final name = function.name;
      if (name != null) functions[name] = renderType(function.returnType);
    }

    final methods = <String, String>{};
    for (final cls in library.classes) {
      final className = cls.name;
      if (className == null) continue;
      for (final method in cls.methods) {
        final name = method.name;
        if (name != null) {
          methods['$className.$name'] = renderType(method.returnType);
        }
      }
    }

    return ResolvedReturnTypes(functions, methods);
  }
}

/// Aliases the generator recognises by name. Expanding these would lose the
/// signal — `Paged<T>` resolves to `Future<PaginatedResponse<T, K>>`, and the
/// page-key argument would then be read as part of the data type.
const _preservedAliases = {'Paged'};

/// Renders [type] the way it would be written in source, but with type
/// aliases expanded to what they stand for.
///
/// `DartType.getDisplayString()` prints the alias name when one was used,
/// which is exactly what we're trying to see past — so the structure is walked
/// directly instead.
String renderType(DartType type) {
  final alias = type.alias;
  if (alias != null && _preservedAliases.contains(alias.element.name)) {
    final args = alias.typeArguments;
    final name = alias.element.name;
    return args.isEmpty
        ? '$name${_suffix(type)}'
        : '$name<${args.map(renderType).join(', ')}>${_suffix(type)}';
  }

  if (type is InterfaceType) {
    final name = type.element.name;
    if (name == null) return type.getDisplayString();
    final args = type.typeArguments;
    return args.isEmpty
        ? '$name${_suffix(type)}'
        : '$name<${args.map(renderType).join(', ')}>${_suffix(type)}';
  }

  return type.getDisplayString();
}

String _suffix(DartType type) =>
    type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
