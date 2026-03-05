import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velotask/l10n/app_localizations.dart';
import 'package:velotask/models/todo.dart';
import 'package:velotask/utils/priority_engine.dart';

class NotificationService {
  static const String _channelId = 'velotask_priority';
  static const String _channelName = 'Task Reminders';
  static const String _channelDescription =
      'Priority and deadline reminder notifications';
  static const String _statePrefix = 'notif_state_';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(settings);

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> syncForTodos(List<Todo> todos, AppLocalizations l10n) async {
    if (!_initialized) {
      await initialize();
    }

    final prefs = await SharedPreferences.getInstance();
    final activeIds = todos.map((todo) => todo.id).toSet();
    final now = DateTime.now();

    for (final todo in todos) {
      final stateKey = '$_statePrefix${todo.id}';
      final previousState = prefs.getString(stateKey);
      final previousTier = _parseTier(previousState);
      final previousNear24 = _parseFlag(previousState, 'near24h');
      final previousNear3 = _parseFlag(previousState, 'near3h');
      final previousOverdue = _parseFlag(previousState, 'overdue');

      final tier = PriorityEngine.notificationTier(
        todo,
        now: now,
        allTodos: todos,
      );
      var near24 = false;
      var near3 = false;
      var overdue = false;

      final ddl = todo.ddl;
      if (ddl != null && !todo.isCompleted) {
        final hoursLeft = ddl.difference(now).inMinutes / 60.0;
        near24 = hoursLeft <= 24 && hoursLeft > 3;
        near3 = hoursLeft <= 3 && hoursLeft > 0;
        overdue = hoursLeft <= 0;
      }

      if (!todo.isCompleted) {
        if (_isTierHigher(tier, previousTier) && _isTierNotifiable(tier)) {
          await _showNotification(
            id: todo.id * 10 + 1,
            title: l10n.notifyPriorityTitle,
            body: '${todo.title} • ${_tierText(tier, l10n)}',
          );
        }

        if (near24 && !previousNear24) {
          await _showNotification(
            id: todo.id * 10 + 2,
            title: l10n.notifyDueSoonTitle,
            body: '${todo.title} • ${l10n.notifyDue24hBody}',
          );
        }

        if (near3 && !previousNear3) {
          await _showNotification(
            id: todo.id * 10 + 3,
            title: l10n.notifyDueSoonTitle,
            body: '${todo.title} • ${l10n.notifyDue3hBody}',
          );
        }

        if (overdue && !previousOverdue) {
          await _showNotification(
            id: todo.id * 10 + 4,
            title: l10n.notifyOverdueTitle,
            body: '${todo.title} • ${l10n.notifyOverdueBody}',
          );
        }
      }

      if (todo.isCompleted) {
        await prefs.remove(stateKey);
      } else {
        await prefs.setString(
          stateKey,
          _encodeState(
            tier: tier,
            near24h: near24 || previousNear24,
            near3h: near3 || previousNear3,
            overdue: overdue || previousOverdue,
          ),
        );
      }
    }

    await _cleanupRemovedTodoStates(prefs, activeIds);
  }

  Future<void> _cleanupRemovedTodoStates(
    SharedPreferences prefs,
    Set<int> activeIds,
  ) async {
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(_statePrefix))
        .toList();
    for (final key in keys) {
      final id = int.tryParse(key.substring(_statePrefix.length));
      if (id == null || activeIds.contains(id)) {
        continue;
      }
      await prefs.remove(key);
    }
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();

    const details = NotificationDetails(android: android, iOS: ios);
    await _plugin.show(id, title, body, details);
  }

  bool _isTierNotifiable(PriorityNotificationTier tier) {
    return tier == PriorityNotificationTier.medium ||
        tier == PriorityNotificationTier.high;
  }

  bool _isTierHigher(
    PriorityNotificationTier current,
    PriorityNotificationTier previous,
  ) {
    return _tierRank(current) > _tierRank(previous);
  }

  int _tierRank(PriorityNotificationTier tier) {
    return switch (tier) {
      PriorityNotificationTier.none => 0,
      PriorityNotificationTier.low => 1,
      PriorityNotificationTier.medium => 2,
      PriorityNotificationTier.high => 3,
    };
  }

  String _tierText(PriorityNotificationTier tier, AppLocalizations l10n) {
    return switch (tier) {
      PriorityNotificationTier.high => l10n.priorityHigh,
      PriorityNotificationTier.medium => l10n.priorityMed,
      PriorityNotificationTier.low => l10n.priorityLow,
      PriorityNotificationTier.none => l10n.filterActive,
    };
  }

  PriorityNotificationTier _parseTier(String? rawState) {
    if (rawState == null) {
      return PriorityNotificationTier.none;
    }
    final parts = rawState.split('|');
    final tierValue = int.tryParse(parts.isEmpty ? '0' : parts.first) ?? 0;
    return switch (tierValue) {
      3 => PriorityNotificationTier.high,
      2 => PriorityNotificationTier.medium,
      1 => PriorityNotificationTier.low,
      _ => PriorityNotificationTier.none,
    };
  }

  bool _parseFlag(String? rawState, String name) {
    if (rawState == null) {
      return false;
    }
    return rawState.split('|').skip(1).any((e) => e == name);
  }

  String _encodeState({
    required PriorityNotificationTier tier,
    required bool near24h,
    required bool near3h,
    required bool overdue,
  }) {
    final flags = <String>[];
    if (near24h) {
      flags.add('near24h');
    }
    if (near3h) {
      flags.add('near3h');
    }
    if (overdue) {
      flags.add('overdue');
    }
    return '${_tierRank(tier)}|${flags.join('|')}';
  }
}
