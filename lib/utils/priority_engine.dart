import 'package:velotask/models/todo.dart';

enum PriorityNotificationTier { none, low, medium, high }

class PriorityEngine {
  const PriorityEngine._();

  static double score(Todo todo, {DateTime? now}) {
    if (todo.isCompleted) {
      return -1;
    }

    final current = now ?? DateTime.now();

    final importanceScore = switch (todo.importance) {
      <= 0 => 28.0,
      1 => 56.0,
      _ => 84.0,
    };

    final ddl = todo.ddl;
    if (ddl == null) {
      return importanceScore + 8;
    }

    final hours = ddl.difference(current).inMinutes / 60.0;
    final dueScore = _dueScore(hours);

    return importanceScore + dueScore;
  }

  static int compare(Todo a, Todo b, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final sa = score(a, now: current);
    final sb = score(b, now: current);

    final scoreCompare = sb.compareTo(sa);
    if (scoreCompare != 0) {
      return scoreCompare;
    }

    final ddlA = a.ddl;
    final ddlB = b.ddl;
    if (ddlA != null && ddlB != null) {
      final ddlCompare = ddlA.compareTo(ddlB);
      if (ddlCompare != 0) {
        return ddlCompare;
      }
    } else if (ddlA != null) {
      return -1;
    } else if (ddlB != null) {
      return 1;
    }

    return a.id.compareTo(b.id);
  }

  static PriorityNotificationTier notificationTier(Todo todo, {DateTime? now}) {
    final s = score(todo, now: now);
    if (s < 0) {
      return PriorityNotificationTier.none;
    }
    if (s >= 145) {
      return PriorityNotificationTier.high;
    }
    if (s >= 95) {
      return PriorityNotificationTier.medium;
    }
    if (s >= 55) {
      return PriorityNotificationTier.low;
    }
    return PriorityNotificationTier.none;
  }

  static double _dueScore(double hoursToDeadline) {
    if (hoursToDeadline <= 0) {
      return 110;
    }
    if (hoursToDeadline <= 3) {
      return 96;
    }
    if (hoursToDeadline <= 12) {
      return 82;
    }
    if (hoursToDeadline <= 24) {
      return 66;
    }
    if (hoursToDeadline <= 72) {
      return 46;
    }
    if (hoursToDeadline <= 168) {
      return 28;
    }
    if (hoursToDeadline <= 336) {
      return 16;
    }
    return 6;
  }
}
