class InvalidApiKeyException implements Exception {
  const InvalidApiKeyException(this.message);

  final String message;

  @override
  String toString() => 'InvalidApiKeyException: $message';
}
