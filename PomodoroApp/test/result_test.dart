import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/utils/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('isSuccess returns true', () {
        const result = Success<int, String>(42);
        expect(result.isSuccess, true);
        expect(result.isFailure, false);
      });

      test('value returns the data', () {
        const result = Success<int, String>(42);
        expect(result.value, 42);
      });

      test('valueOrNull returns the data', () {
        const result = Success<int, String>(42);
        expect(result.valueOrNull, 42);
      });

      test('error throws StateError', () {
        const result = Success<int, String>(42);
        expect(() => result.error, throwsA(isA<StateError>()));
      });

      test('map transforms value correctly', () {
        const result = Success<int, String>(42);
        final mapped = result.map((v) => v * 2);
        expect(mapped.value, 84);
      });

      test('flatMap transforms value correctly', () {
        const result = Success<int, String>(42);
        final flatMapped = result.flatMap((v) => Success<String, String>('Value: $v'));
        expect(flatMapped.value, 'Value: 42');
      });

      test('fold calls onSuccess', () {
        const result = Success<int, String>(42);
        final folded = result.fold(
          onSuccess: (v) => 'Success: $v',
          onFailure: (e) => 'Failure: $e',
        );
        expect(folded, 'Success: 42');
      });

      test('getOrElse returns value', () {
        const result = Success<int, String>(42);
        expect(result.getOrElse(0), 42);
      });

      test('equality works correctly', () {
        const result1 = Success<int, String>(42);
        const result2 = Success<int, String>(42);
        const result3 = Success<int, String>(99);

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });
    });

    group('Failure', () {
      test('isFailure returns true', () {
        const result = Failure<int, String>('error');
        expect(result.isFailure, true);
        expect(result.isSuccess, false);
      });

      test('error returns the error data', () {
        const result = Failure<int, String>('error');
        expect(result.error, 'error');
      });

      test('value throws StateError', () {
        const result = Failure<int, String>('error');
        expect(() => result.value, throwsA(isA<StateError>()));
      });

      test('valueOrNull returns null', () {
        const result = Failure<int, String>('error');
        expect(result.valueOrNull, null);
      });

      test('map returns Failure unchanged', () {
        const result = Failure<int, String>('error');
        final mapped = result.map((v) => v * 2);
        expect(mapped.isFailure, true);
        expect(mapped.error, 'error');
      });

      test('flatMap returns Failure unchanged', () {
        const result = Failure<int, String>('error');
        final flatMapped = result.flatMap((v) => Success<String, String>('Value: $v'));
        expect(flatMapped.isFailure, true);
        expect(flatMapped.error, 'error');
      });

      test('fold calls onFailure', () {
        const result = Failure<int, String>('error');
        final folded = result.fold(
          onSuccess: (v) => 'Success: $v',
          onFailure: (e) => 'Failure: $e',
        );
        expect(folded, 'Failure: error');
      });

      test('getOrElse returns default value', () {
        const result = Failure<int, String>('error');
        expect(result.getOrElse(99), 99);
      });

      test('getOrCompute computes default from error', () {
        const result = Failure<int, String>('error');
        expect(result.getOrCompute((e) => e.length), 5);
      });

      test('equality works correctly', () {
        const result1 = Failure<int, String>('error');
        const result2 = Failure<int, String>('error');
        const result3 = Failure<int, String>('other');

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });
    });
  });

  group('AppError', () {
    test('has correct messages', () {
      expect(AppError.notFound.message, 'Resource not found');
      expect(AppError.invalidInput.message, 'Invalid input provided');
      expect(AppError.storageError.message, 'Storage operation failed');
      expect(AppError.networkError.message, 'Network operation failed');
      expect(AppError.permissionDenied.message, 'Permission denied');
      expect(AppError.unknown.message, 'An unknown error occurred');
    });
  });
}
