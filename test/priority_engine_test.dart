import 'package:flutter_test/flutter_test.dart';
import 'package:velotask/models/todo.dart';
import 'package:velotask/utils/priority_engine.dart';

void main() {
  group('PriorityEngine.score', () {
    final now = DateTime(2026, 3, 5, 10);

    test('higher importance gets higher score when deadline is same', () {
      final low = Todo(
        title: 'low',
        importance: 0,
        ddl: now.add(const Duration(days: 3)),
      );
      final medium = Todo(
        title: 'medium',
        importance: 1,
        ddl: now.add(const Duration(days: 3)),
      );
      final high = Todo(
        title: 'high',
        importance: 2,
        ddl: now.add(const Duration(days: 3)),
      );

      expect(
        PriorityEngine.score(high, now: now),
        greaterThan(PriorityEngine.score(medium, now: now)),
      );
      expect(
        PriorityEngine.score(medium, now: now),
        greaterThan(PriorityEngine.score(low, now: now)),
      );
    });

    test('near deadline gets higher score when importance is same', () {
      final near = Todo(
        title: 'near',
        importance: 1,
        ddl: now.add(const Duration(hours: 8)),
      );
      final far = Todo(
        title: 'far',
        importance: 1,
        ddl: now.add(const Duration(days: 20)),
      );

      expect(
        PriorityEngine.score(near, now: now),
        greaterThan(PriorityEngine.score(far, now: now)),
      );
    });

    test('completed todo is deprioritized', () {
      final done = Todo(
        title: 'done',
        importance: 2,
        ddl: now.add(const Duration(hours: 2)),
        isCompleted: true,
      );

      expect(PriorityEngine.score(done, now: now), lessThan(0));
    });
  });

  group('PriorityEngine.compare', () {
    final now = DateTime(2026, 3, 5, 10);

    test('orders by priority descending', () {
      final a = Todo(
        title: 'A',
        importance: 0,
        ddl: now.add(const Duration(days: 10)),
      );
      final b = Todo(
        title: 'B',
        importance: 2,
        ddl: now.add(const Duration(days: 2)),
      );
      final c = Todo(
        title: 'C',
        importance: 1,
        ddl: now.add(const Duration(hours: 6)),
      );

      final list = [a, b, c]
        ..sort((x, y) => PriorityEngine.compare(x, y, now: now));

      expect(list.first.title, anyOf('B', 'C'));
      expect(list.last.title, 'A');
    });
  });

  group('PriorityEngine.notificationTier', () {
    final now = DateTime(2026, 3, 5, 10);

    test('high tier for high importance and very near deadline', () {
      final todo = Todo(
        title: 'urgent',
        importance: 2,
        ddl: now.add(const Duration(hours: 2)),
      );
      expect(
        PriorityEngine.notificationTier(todo, now: now),
        PriorityNotificationTier.high,
      );
    });

    test('none tier for completed tasks', () {
      final todo = Todo(
        title: 'done',
        importance: 2,
        ddl: now.add(const Duration(hours: 2)),
        isCompleted: true,
      );
      expect(
        PriorityEngine.notificationTier(todo, now: now),
        PriorityNotificationTier.none,
      );
    });
  });

  group('PriorityEngine deadline ranges', () {
    final now = DateTime(2026, 3, 5, 10);

    Todo mediumTodoAt(Duration offset) {
      return Todo(title: 'range', importance: 1, ddl: now.add(offset));
    }

    test('bucket boundaries produce expected scores and tiers', () {
      final cases =
          <({Duration offset, double score, PriorityNotificationTier tier})>[
            (
              offset: const Duration(hours: -1),
              score: 166,
              tier: PriorityNotificationTier.high,
            ),
            (
              offset: const Duration(hours: 3),
              score: 152,
              tier: PriorityNotificationTier.high,
            ),
            (
              offset: const Duration(hours: 12),
              score: 138,
              tier: PriorityNotificationTier.medium,
            ),
            (
              offset: const Duration(hours: 24),
              score: 122,
              tier: PriorityNotificationTier.medium,
            ),
            (
              offset: const Duration(hours: 72),
              score: 102,
              tier: PriorityNotificationTier.medium,
            ),
            (
              offset: const Duration(hours: 168),
              score: 84,
              tier: PriorityNotificationTier.low,
            ),
            (
              offset: const Duration(hours: 336),
              score: 72,
              tier: PriorityNotificationTier.low,
            ),
            (
              offset: const Duration(hours: 500),
              score: 62,
              tier: PriorityNotificationTier.low,
            ),
          ];

      for (final c in cases) {
        final todo = mediumTodoAt(c.offset);
        expect(PriorityEngine.score(todo, now: now), c.score);
        expect(PriorityEngine.notificationTier(todo, now: now), c.tier);
      }
    });

    test('scores step down right after boundary points', () {
      final at24 = PriorityEngine.score(
        mediumTodoAt(const Duration(hours: 24)),
        now: now,
      );
      final after24 = PriorityEngine.score(
        mediumTodoAt(const Duration(hours: 25)),
        now: now,
      );
      final at72 = PriorityEngine.score(
        mediumTodoAt(const Duration(hours: 72)),
        now: now,
      );
      final after72 = PriorityEngine.score(
        mediumTodoAt(const Duration(hours: 73)),
        now: now,
      );

      expect(after24, lessThan(at24));
      expect(after72, lessThan(at72));
    });

    test('urgency rises quickly in the last 24 hours', () {
      final at48 = PriorityEngine.score(
        mediumTodoAt(const Duration(hours: 48)),
        now: now,
      );
      final at24 = PriorityEngine.score(
        mediumTodoAt(const Duration(hours: 24)),
        now: now,
      );
      final at12 = PriorityEngine.score(
        mediumTodoAt(const Duration(hours: 12)),
        now: now,
      );
      final at3 = PriorityEngine.score(
        mediumTodoAt(const Duration(hours: 3)),
        now: now,
      );

      expect(at24 - at48, greaterThanOrEqualTo(20));
      expect(at12 - at24, greaterThanOrEqualTo(16));
      expect(at3 - at12, greaterThanOrEqualTo(12));
    });
  });
}
