class RocketChatException implements Exception {
  final String message;
  final String? serviceClass;
  final String method;
  final Object? error;
  final String stacktrace;

  RocketChatException(
    this.message,
    this.serviceClass,
    this.method,
    this.error,
    this.stacktrace,
  );

  @override
  String toString() {
    return '''RocketChatException: 
      ${serviceClass != null ? 'Service: $serviceClass' : ''}
      Method: $method
      Error: $message
      Error: $error
      Stacktrace: $stacktrace
    ''';
  }
}
