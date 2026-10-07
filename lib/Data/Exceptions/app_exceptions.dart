class AppExceptions implements Exception {
  final dynamic _message;
  final dynamic statuscode;

  AppExceptions([this._message, this.statuscode]);

  String? get message => _message?.toString();

  @override
  String toString() => '$statuscode $_message';
}

class FetchDataException extends AppExceptions {
  FetchDataException([String? super.messages, int? super.statusCode]);
}

class BadRequestException extends AppExceptions {
  BadRequestException([String? super.messages, int? super.statusCode]);
}

class UnauthorisedException extends AppExceptions {
  UnauthorisedException([String? super.messages, int? super.statusCode]);
}

class InavalidInputException extends AppExceptions {
  InavalidInputException([String? super.messages, int? super.statusCode]);
}

class NotFoundException extends AppExceptions {
  NotFoundException([String? super.messages, int? super.statusCode]);
}

class ConflictException extends AppExceptions {
  ConflictException([String? super.messages, int? super.statusCode]);
}

class GoneException extends AppExceptions {
  GoneException([String? super.messages, int? super.statusCode]);
}

class ValidationException extends AppExceptions {
  ValidationException([String? super.messages, int? super.statusCode]);
}

class RateLimitException extends AppExceptions {
  RateLimitException([String? super.messages, int? super.statusCode]);
}

class ServiceUnavailableException extends AppExceptions {
  ServiceUnavailableException([String? super.messages, int? super.statusCode]);
}

class NetworkTimeoutException extends AppExceptions {
  NetworkTimeoutException([String? super.messages, int? super.statusCode]);
}

class NoInternetException extends AppExceptions {
  NoInternetException([
    String super.messages = 'No internet connection',
    int? super.statusCode,
  ]);
}
