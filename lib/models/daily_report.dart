import 'package:flutter/foundation.dart';

class DailyReport {
  final DateTime date;
  final DateTime loginTime;
  final DateTime logoutTime;
  final Duration totalWorkTime;
  final Duration idleTime;
  final int totalTasksAssigned;
  final int totalTasksCompleted;
  final int totalPendingTasks;
  final int totalActiveSessions;

  DailyReport({
    required this.date,
    required this.loginTime,
    required this.logoutTime,
    required this.totalWorkTime,
    required this.idleTime,
    required this.totalTasksAssigned,
    required this.totalTasksCompleted,
    required this.totalPendingTasks,
    required this.totalActiveSessions,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'loginTime': loginTime.toIso8601String(),
      'logoutTime': logoutTime.toIso8601String(),
      'totalWorkTime': totalWorkTime.inSeconds,
      'idleTime': idleTime.inSeconds,
      'totalTasksAssigned': totalTasksAssigned,
      'totalTasksCompleted': totalTasksCompleted,
      'totalPendingTasks': totalPendingTasks,
      'totalActiveSessions': totalActiveSessions,
    };
  }
}
