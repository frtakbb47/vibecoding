/// A Result type for better error handling
///
/// Instead of throwing exceptions or returning null,
/// functions can return a Result that explicitly communicates
/// success or failure along with the associated data or error.
sealed class Result<T, E> {
  const Result();

  /// Returns true if this is a Success result
  bool get isSuccess => this is Success<T, E>;

  /// Returns true if this is a Failure result
  bool get isFailure => this is Failure<T, E>;

  /// Gets the value if Success, throws if Failure
  T get value {
    if (this is Success<T, E>) {
      return (this as Success<T, E>).data;
    }
    throw StateError('Cannot get value from Failure result');
  }

  /// Gets the error if Failure, throws if Success
  E get error {
    if (this is Failure<T, E>) {
      return (this as Failure<T, E>).errorData;
    }
    throw StateError('Cannot get error from Success result');
  }

  /// Gets the value or null if Failure
  T? get valueOrNull {
    if (this is Success<T, E>) {
      return (this as Success<T, E>).data;
    }
    return null;
  }

  /// Transforms the value if Success, returns Failure unchanged
  Result<R, E> map<R>(R Function(T) transform) {
    if (this is Success<T, E>) {
      return Success(transform((this as Success<T, E>).data));
    }
    return Failure((this as Failure<T, E>).errorData);
  }

  /// Transforms the value if Success with a function that returns Result
  Result<R, E> flatMap<R>(Result<R, E> Function(T) transform) {
    if (this is Success<T, E>) {
      return transform((this as Success<T, E>).data);
    }
    return Failure((this as Failure<T, E>).errorData);
  }

  /// Applies [onSuccess] if Success, [onFailure] if Failure
  R fold<R>({
    required R Function(T) onSuccess,
    required R Function(E) onFailure,
  }) {
    if (this is Success<T, E>) {
      return onSuccess((this as Success<T, E>).data);
    }
    return onFailure((this as Failure<T, E>).errorData);
  }

  /// Gets value or returns [defaultValue] if Failure
  T getOrElse(T defaultValue) {
    if (this is Success<T, E>) {
      return (this as Success<T, E>).data;
    }
    return defaultValue;
  }

  /// Gets value or computes default using [compute] if Failure
  T getOrCompute(T Function(E) compute) {
    if (this is Success<T, E>) {
      return (this as Success<T, E>).data;
    }
    return compute((this as Failure<T, E>).errorData);
  }
}

/// Represents a successful result with data of type T
class Success<T, E> extends Result<T, E> {
  final T data;
  const Success(this.data);

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> && runtimeType == other.runtimeType && data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Represents a failed result with error of type E
class Failure<T, E> extends Result<T, E> {
  final E errorData;
  const Failure(this.errorData);

  @override
  String toString() => 'Failure($errorData)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> && runtimeType == other.runtimeType && errorData == other.errorData;

  @override
  int get hashCode => errorData.hashCode;
}

/// Common error types for the app
enum AppError {
  notFound('Resource not found'),
  invalidInput('Invalid input provided'),
  storageError('Storage operation failed'),
  networkError('Network operation failed'),
  permissionDenied('Permission denied'),
  unknown('An unknown error occurred');

  final String message;
  const AppError(this.message);
}
