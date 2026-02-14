import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/utils/extensions.dart';

void main() {
  group('DurationExtensions', () {
    test('toReadableString returns correct format for hours and minutes', () {
      expect(const Duration(hours: 2, minutes: 30).toReadableString(), '2h 30m');
      expect(const Duration(hours: 1, minutes: 0).toReadableString(), '1h 0m');
      expect(const Duration(hours: 0, minutes: 45).toReadableString(), '45m');
      expect(const Duration(hours: 0, minutes: 5).toReadableString(), '5m');
    });

    test('toTimerString returns correct format', () {
      expect(const Duration(hours: 1, minutes: 30, seconds: 45).toTimerString(), '01:30:45');
      expect(const Duration(minutes: 25, seconds: 0).toTimerString(), '25:00');
      expect(const Duration(minutes: 5, seconds: 30).toTimerString(), '05:30');
      expect(const Duration(seconds: 45).toTimerString(), '00:45');
    });
  });

  group('DateTimeExtensions', () {
    test('isSameDay returns true for same day', () {
      final date1 = DateTime(2024, 1, 15, 10, 30);
      final date2 = DateTime(2024, 1, 15, 18, 45);
      expect(date1.isSameDay(date2), true);
    });

    test('isSameDay returns false for different days', () {
      final date1 = DateTime(2024, 1, 15);
      final date2 = DateTime(2024, 1, 16);
      expect(date1.isSameDay(date2), false);
    });

    test('isToday returns true for today', () {
      final today = DateTime.now();
      expect(today.isToday, true);
    });

    test('isToday returns false for other days', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isToday, false);
    });

    test('isYesterday returns true for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isYesterday, true);
    });

    test('startOfDay returns midnight', () {
      final date = DateTime(2024, 1, 15, 14, 30, 45);
      final startOfDay = date.startOfDay;
      expect(startOfDay.hour, 0);
      expect(startOfDay.minute, 0);
      expect(startOfDay.second, 0);
    });

    test('endOfDay returns 23:59:59', () {
      final date = DateTime(2024, 1, 15, 14, 30, 45);
      final endOfDay = date.endOfDay;
      expect(endOfDay.hour, 23);
      expect(endOfDay.minute, 59);
      expect(endOfDay.second, 59);
    });
  });

  group('StringExtensions', () {
    test('capitalize capitalizes first letter', () {
      expect('hello'.capitalize(), 'Hello');
      expect('HELLO'.capitalize(), 'HELLO');
      expect(''.capitalize(), '');
      expect('a'.capitalize(), 'A');
    });

    test('truncate shortens string correctly', () {
      expect('Hello World'.truncate(20), 'Hello World');
      expect('Hello World'.truncate(8), 'Hello...');
      expect('Hi'.truncate(5), 'Hi');
    });
  });

  group('IntExtensions', () {
    test('toReadableDuration formats minutes correctly', () {
      expect(25.toReadableDuration(), '25 min');
      expect(60.toReadableDuration(), '1 hour');
      expect(90.toReadableDuration(), '1h 30m');
      expect(120.toReadableDuration(), '2 hours');
      expect(5.toReadableDuration(), '5 min');
    });
  });

  group('ListExtensions', () {
    test('getOrNull returns element at valid index', () {
      final list = [1, 2, 3, 4, 5];
      expect(list.getOrNull(0), 1);
      expect(list.getOrNull(2), 3);
      expect(list.getOrNull(4), 5);
    });

    test('getOrNull returns null for invalid index', () {
      final list = [1, 2, 3];
      expect(list.getOrNull(-1), null);
      expect(list.getOrNull(3), null);
      expect(list.getOrNull(100), null);
    });

    test('groupBy groups elements correctly', () {
      final numbers = [1, 2, 3, 4, 5, 6];
      final grouped = numbers.groupBy((n) => n % 2 == 0 ? 'even' : 'odd');

      expect(grouped['even'], [2, 4, 6]);
      expect(grouped['odd'], [1, 3, 5]);
    });

    test('groupBy handles empty list', () {
      final emptyList = <int>[];
      final grouped = emptyList.groupBy((n) => n);
      expect(grouped.isEmpty, true);
    });
  });
}
