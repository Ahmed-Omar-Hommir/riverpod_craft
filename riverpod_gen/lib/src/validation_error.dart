class ValidationResponse {
  final String? type;
  final String? titleValue;
  final String? messageValue;
  final Map<String, List<dynamic>> errors;

  const ValidationResponse({
    required this.type,
    required this.titleValue,
    required this.messageValue,
    required this.errors,
  });

  String? get message => titleValue ?? messageValue;

  factory ValidationResponse.fromJson(Map<String, dynamic> json) {
    return ValidationResponse(
      type: json['type'] as String?,
      titleValue: json['title'] as String?,
      messageValue: json['message'] as String?,
      errors: (json['errors'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as List<dynamic>)),
          ) ??
          {},
    );
  }
}
