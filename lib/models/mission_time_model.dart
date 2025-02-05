import 'package:flutter/material.dart';
import 'package:notiyou/utils/time_utils.dart';

class MissionTime {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String challengerId;
  final TimeOfDay missionAt;
  final String? supporterId;

  MissionTime({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.challengerId,
    required this.missionAt,
    required this.supporterId,
  });

  factory MissionTime.fromJson({
    required int id,
    required String createdAt,
    required String updatedAt,
    required String challengerId,
    required String missionAt,
    required String? supporterId,
  }) =>
      MissionTime(
        id: id,
        createdAt: TimeUtils.parseDate(createdAt),
        updatedAt: TimeUtils.parseDate(updatedAt),
        challengerId: challengerId,
        missionAt: TimeUtils.parseTime(missionAt),
        supporterId: supporterId,
      );

  MissionTime copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? challengerId,
    TimeOfDay? missionAt,
    String? supporterId,
  }) {
    return MissionTime(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      challengerId: challengerId ?? this.challengerId,
      missionAt: missionAt ?? this.missionAt,
      supporterId: supporterId ?? this.supporterId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': TimeUtils.stringifyDate(createdAt),
        'updated_at': TimeUtils.stringifyDate(updatedAt),
        'challenger_id': challengerId,
        'mission_at': TimeUtils.stringifyTime(missionAt),
        'supporter_id': supporterId,
      };
}
