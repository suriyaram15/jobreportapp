import 'package:flutter/foundation.dart';
import 'package:jobreport/models/period.dart';

@immutable
class Task {
  final String taskId;
  final DateTime createdAt;
  final String description;
  final String status; // e.g., 'Active', 'Completed'
  final List<Period> periods;

  const Task({
    required this.taskId,
    required this.createdAt,
    required this.description,
    required this.status,
    this.periods = const [],
  });

  Duration getWorkedDuration(DateTime fallbackEnd) {
    return periods.fold(Duration.zero, (total, p) {
      if (p.type == 'active' || p.type == 'on-meeting') {
        return total + p.getDuration(fallbackEnd);
      }
      return total;
    });
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    var periodsList = <Period>[];
    if (json['periods'] != null) {
      var periodsJson = json['periods'] as List;
      periodsList = periodsJson.map((p) => Period.fromJson(p)).toList();
    }

    return Task(
      taskId: json['taskId'],
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'] ?? '',
      status: json['status'] ?? 'Active',
      periods: periodsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'status': status,
      'periods': periods.map((p) => p.toJson()).toList(),
    };
  }
}
