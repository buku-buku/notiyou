import 'package:flutter/material.dart';

import '../utils/time_utils.dart';

class Mission {
  final String id;
  final TimeOfDay time;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime date;

  Mission({
    required this.id,
    required this.time,
    required this.isCompleted,
    this.completedAt,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': TimeUtils.stringifyTime(time),
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'date': date.toIso8601String(),
      };

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
        id: json['id'],
        time: TimeUtils.parseTime(json['time']),
        isCompleted: json['isCompleted'],
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        date: DateTime.parse(json['date']),
      );

  bool get expired {
    if (isCompleted) return false;
    final now = DateTime.now();
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).isBefore(now);
  }

  String? get formattedCompletedTime {
    if (completedAt == null) return null;
    return '${completedAt!.hour.toString().padLeft(2, '0')}:${completedAt!.minute.toString().padLeft(2, '0')}';
  }
}
