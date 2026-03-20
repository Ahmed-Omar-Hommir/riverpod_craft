class ParameterInfo {
  const ParameterInfo({
    required this.name,
    required this.type,
    required this.isRequired,
    required this.defaultValue,
    required this.isPositional,
    this.isFamily = false,
  });

  final String name;
  final String type;
  final bool isRequired;
  final String? defaultValue;
  final bool isPositional;
  final bool isFamily;
}
