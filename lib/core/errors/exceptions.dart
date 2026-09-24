class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'An unexpected server error occurred']);
}

class CacheException implements Exception {}
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException([this.message = 'Authentication failed']);
}
