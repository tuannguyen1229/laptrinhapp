class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);
  
  @override
  String toString() => 'DatabaseException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

class CameraException implements Exception {
  final String message;
  const CameraException(this.message);
  
  @override
  String toString() => 'CameraException: $message';
}

class NotificationException implements Exception {
  final String message;
  const NotificationException(this.message);
  
  @override
  String toString() => 'NotificationException: $message';
}

class PermissionException implements Exception {
  final String message;
  const PermissionException(this.message);
  
  @override
  String toString() => 'PermissionException: $message';
}

class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}