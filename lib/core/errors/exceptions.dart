/// Core exceptions for the application
/// These exceptions represent different error scenarios in the Clean Architecture

/// Base exception class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when there's a problem with local storage operations
class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}

/// Exception thrown when there's a problem with data validation
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

/// Exception thrown when there's a problem with notifications
class NotificationException extends AppException {
  const NotificationException(super.message, {super.code});
}

/// Exception thrown when there's a network-related problem
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

/// Exception thrown when a requested resource is not found
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});
}

/// Exception thrown when there's a server-side error
class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

/// Exception thrown when there's a caching-related problem
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}