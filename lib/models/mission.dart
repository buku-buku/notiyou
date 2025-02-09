import 'package:flutter/material.dart';

import 'package:notiyou/utils/time_utils.dart';

class Mission {
  final int id;
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

  Mission copyWith({
    int? id,
    TimeOfDay? time,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? date,
  }) {
    final newIsCompleted = isCompleted ?? this.isCompleted;
    return Mission(
      id: id ?? this.id,
      time: time ?? this.time,
      isCompleted: newIsCompleted,
      completedAt: newIsCompleted ? (completedAt ?? this.completedAt) : null,
      date: date ?? this.date,
    );
  }

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

  factory Mission.fromMissionHistoryEntity(Map<String, dynamic> json) =>
      Mission(
        id: json['mission_id'],
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

extension MissionHelpers on Mission {
  Mission withLocalTimes() {
    return copyWith(
      completedAt: completedAt?.toLocal(),
      date: date.toLocal(),
    );
  }
}

/// @example
/// ```dart
/// final missions = await findMissions<Future<List<Mission>>>(DateTime.now());
/// print('missions: ${missions.map((e) => e.debugString())}');
/// ```
extension MissionDebug on Mission {
  // 🤓 debugString()이라는 임의의 메서드를 만들고, 원하는 문자열 형태로 나오도록 작성합니다
  String debugString() {
    return '''
Mission {
  id: $id,
  time: $time,
  isCompleted: $isCompleted,
  completedAt: $completedAt,
  date: $date
}
''';
  }
}
