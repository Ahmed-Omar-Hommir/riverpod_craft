import 'parameter_info.dart';

extension ParametersInfoListExtension on List<ParameterInfo> {
  /// Returns a Dart function parameter string, e.g. "int x, {required int y, String? z = 'foo'}"
  String toParameterSignature() {
    final positional = where((p) => p.isPositional).toList();
    final named = where((p) => !p.isPositional).toList();

    final positionalStr = positional
        .map((p) {
          final def = p.defaultValue != null ? ' = ${p.defaultValue}' : '';
          return '${p.type} ${p.name}$def';
        })
        .join(', ');

    String namedStr = '';
    if (named.isNotEmpty) {
      namedStr =
          '{${named.map((p) {
            final req = p.isRequired ? 'required ' : '';
            final def = p.defaultValue != null ? ' = ${p.defaultValue}' : '';
            return '$req${p.type} ${p.name}$def';
          }).join(', ')}}';
    }

    if (positionalStr.isNotEmpty && namedStr.isNotEmpty) {
      return '$positionalStr, $namedStr';
    } else if (positionalStr.isNotEmpty) {
      return positionalStr;
    } else if (namedStr.isNotEmpty) {
      return namedStr;
    } else {
      return '';
    }
  }

  /// Returns a Dart record type string, e.g. "({int x, String y})"
  String toRecordType() {
    if (isEmpty) return '()';
    return '({${map((p) => '${p.type} ${p.name}').join(', ')}})';
  }

  /// Returns a Dart record value string for passing arguments, e.g. "(x: x, y: y)"
  String toRecordValue() {
    if (isEmpty) return '';
    return '(${map((p) => '${p.name}: ${p.name}').join(', ')})';
  }

  /// Returns a string for passing parameters from a normal function into another normal function.
  /// Usage: for a function with signature (int x, {required int userId, String? tag}),
  /// this returns: "x, userId: userId, tag: tag"
  String toFunctionCallArguments() {
    final positional = where((p) => p.isPositional).toList();
    final named = where((p) => !p.isPositional).toList();

    final positionalStr = positional.map((p) => p.name).join(', ');

    final namedStr = named.map((p) => '${p.name}: ${p.name}').join(', ');

    if (positionalStr.isNotEmpty && namedStr.isNotEmpty) {
      return '$positionalStr, $namedStr';
    } else if (positionalStr.isNotEmpty) {
      return positionalStr;
    } else if (namedStr.isNotEmpty) {
      return namedStr;
    } else {
      return '';
    }
  }

  /// Returns a string for passing record fields to a normal function, e.g. "arg.x, userId: arg.userId, ..."
  /// Usage: for a function with signature (int x, {required int userId, String? tag}), and a record arg,
  /// this returns: "arg.x, userId: arg.userId, tag: arg.tag"
  String fromRecordToFunctionCall([String recordName = 'arg']) {
    final positional = where((p) => p.isPositional).toList();
    final named = where((p) => !p.isPositional).toList();

    final positionalStr = positional
        .map((p) => '$recordName.${p.name}')
        .join(', ');

    final namedStr = named
        .map((p) => '${p.name}: $recordName.${p.name}')
        .join(', ');

    if (positionalStr.isNotEmpty && namedStr.isNotEmpty) {
      return '$positionalStr, $namedStr';
    } else if (positionalStr.isNotEmpty) {
      return positionalStr;
    } else if (namedStr.isNotEmpty) {
      return namedStr;
    } else {
      return '';
    }
  }
}
