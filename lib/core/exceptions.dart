class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error occurred']);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  final int? code;
  ServerException([this.message = 'Server error occurred', this.code]);
  @override
  String toString() => message;
}

class ConnectionTimeoutException implements Exception {
  final String message;
  ConnectionTimeoutException([this.message = 'Connection timed out']);
  @override
  String toString() => message;
}
