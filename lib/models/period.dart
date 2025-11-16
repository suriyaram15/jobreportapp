import 'package:flutter/foundation.dart';

@immutable
class Period {
  final String periodId;
  final DateTime start;
  final DateTime? end;
  final String type; // e.g., 'active', 'idle', 'inactive'
  final String description;

  const Period({
    required this.periodId,
    required this.start,
    this.end,
    required this.type,
    this.description = '',
  });

  Duration getDuration(DateTime? fallbackEnd) {
    final effectiveEnd = end ?? fallbackEnd;
    if (effectiveEnd == null) return Duration.zero;
    return effectiveEnd.difference(start);
  }

  Period copyWith({DateTime? end}) {
    return Period(
      periodId: periodId,
      start: start,
      end: end ?? this.end,
      type: type,
      description: description,
    );
  }

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      periodId: json['periodId'],
      start: DateTime.parse(json['start']),
      end: json['end'] != null ? DateTime.parse(json['end']) : null,
      type: json['type'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodId': periodId,
      'start': start.toIso8601String(),
      'end': end?.toIso8601String(),
      'type': type,
      'description': description,
    };
  }
}
