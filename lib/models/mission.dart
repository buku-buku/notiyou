import 'package:flutter/material.dart';

import '../utils/time_utils.dart';

class Mission {
  final String id;
  final int missionNumber;
  final TimeOfDay time;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime date;

  Mission({
    required this.id,
    required this.missionNumber,
    required this.time,
    required this.isCompleted,
    this.completedAt,
    required this.date,
  });

  Mission copyWith({
    String? id,
    int? missionNumber,
    TimeOfDay? time,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? date,
  }) {
    final newIsCompleted = isCompleted ?? this.isCompleted;
    return Mission(
      id: id ?? this.id,
      missionNumber: missionNumber ?? this.missionNumber,
      time: time ?? this.time,
      isCompleted: newIsCompleted,
      completedAt: newIsCompleted ? (completedAt ?? this.completedAt) : null,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'missionNumber': missionNumber,
        'time': TimeUtils.stringifyTime(time),
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'date': date.toIso8601String(),
      };

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
        id: json['id'],
        missionNumber: json['missionNumber'],
        time: TimeUtils.parseTime(json['time']),
        isCompleted: json['isCompleted'],
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        date: DateTime.parse(json['date']),
      );

  factory Mission.fromMissionHistoryEntity(Map<String, dynamic> json) =>
      Mission(
        id: json['id'].toString(),
        missionNumber: json['missions']['mission_number'],
        time: TimeUtils.parseTime(json['mission_at']),
        isCompleted: json['done_at'] != null,
        completedAt:
            json['done_at'] != null ? DateTime.parse(json['done_at']) : null,
        date: DateTime.parse(json['created_at']),
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
    final localCompletedAt = completedAt!.toLocal();
    return '${localCompletedAt.hour.toString().padLeft(2, '0')}:${localCompletedAt.minute.toString().padLeft(2, '0')}';
  }
}
