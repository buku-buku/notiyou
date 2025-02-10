import 'package:flutter/material.dart';
import 'package:notiyou/models/mission.dart';
import 'package:notiyou/repositories/supabase_table_names_constants.dart';
import 'package:notiyou/repositories/mission_history_repository/mission_history_repository_interface.dart';
import 'package:notiyou/services/supabase_service.dart';
import 'package:notiyou/utils/time_utils.dart';

/// 미션 데이터를 관리하는 저장소입니다.
///
/// 해당 저장소에서는 미션을 조회하고, 수정하는 메서드만 제공됩니다.
///
/// 미션이 생성되는 것은 서버에서 수행될 예정입니다. 클라이언트상에서 생성되는 미션은
/// 인터넷 연결이 불안정한 환경을 대비한 캐싱 목적으로만 존재합니다.
///
/// ⚠️: 로컬의 데이터는 오늘의 데이터만 저장됩니다.
/// 오늘 이후의 모든 데이터는 앱 실행 시 삭제됩니다.
class MissionHistoryRepositoryRemote implements MissionHistoryRepository {
  @override
  Future<Mission?> findMissionById(int id) async {
    final entity = await SupabaseService.client
        .from(SupabaseTableNames.missionHistory)
        .select('''
          id,
          done_at,
          created_at,
          mission_at,
          mission_id
        ''')
        .eq('id', id)
        .single();

    return Mission.fromMissionHistoryEntity(entity);
  }

  @override
  Future<void> init() async {
    // 원격 저장소는 초기화가 필요 없음
    return;
  }

  @override
  Future<void> removeTodayMission(int missionId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await SupabaseService.client
        .from(SupabaseTableNames.missionHistory)
        .delete()
        .eq('mission_id', missionId)
        .gte('created_at', today.toUtc().toIso8601String());
  }

  @override
  Future<void> updateMission(Mission mission) async {
    if (mission.completedAt == null) {
      await SupabaseService.client
          .from(SupabaseTableNames.missionHistory)
          .update({
        'done_at': null,
      }).eq('id', mission.id);
    } else {
      await SupabaseService.client
          .from(SupabaseTableNames.missionHistory)
          .update({
        'done_at': mission.completedAt!.toUtc().toIso8601String(),
      }).eq('id', mission.id);
    }
  }

  @override
  Future<void> createTodayMission(int missionId) async {
    final missionTime = await SupabaseService.client
        .from(SupabaseTableNames.missionTime)
        .select('id, mission_at')
        .eq('id', missionId)
        .single();

    await SupabaseService.client
        .from(SupabaseTableNames.missionHistory)
        .insert({
      'mission_id': missionTime['id'],
      'mission_at': missionTime['mission_at'],
    });
  }

  @override
  Future<bool> hasTodayMission(int missionId) async {
    final missions = await findMissions(DateTime.now());
    return missions.any((e) => e.id == missionId);
  }

  @override
  Future<void> updateTodayMissionTime(int missionId, TimeOfDay time) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mission = await SupabaseService.client
        .from(SupabaseTableNames.missionTime)
        .select('id')
        .eq('id', missionId)
        .single();

    await SupabaseService.client
        .from(SupabaseTableNames.missionHistory)
        .update({
          'mission_at': TimeUtils.stringifyTime(time),
        })
        .eq('mission_id', mission['id'])
        .gte('created_at', today.toUtc().toIso8601String());
  }

  @override
  Future<List<Mission>> findMissions(DateTime date) async {
    final today = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    try {
      final missionHistoryEntities = await SupabaseService.client
          .from(SupabaseTableNames.missionHistory)
          .select('''
          id,
          done_at,
          created_at,
          mission_at,
          mission_id
        ''')
          .gte('created_at', yesterday.toUtc().toIso8601String())
          .lt('created_at', tomorrow.toUtc().toIso8601String())
          .order('mission_at', ascending: true);

      return missionHistoryEntities
          .map((e) => _syncEntityTimeZone(entity: e, baseDate: date))
          .where((e) {
            final createdAt = DateTime.parse(e['created_at']);
            return createdAt.year == date.year &&
                createdAt.month == date.month &&
                createdAt.day == date.day;
          })
          .map((e) => Mission.fromMissionHistoryEntity(e))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future<List<Mission>> findAllMissions() async {
    final missionHistoryEntities = await SupabaseService.client
        .from(SupabaseTableNames.missionHistory)
        .select('''
        id,
        done_at,
        created_at,
        mission_at,
        mission_id
      ''');

    final missions = missionHistoryEntities
        .map((e) => Mission.fromMissionHistoryEntity(e))
        .toList();

    missions.sort((a, b) => a.id.compareTo(b.id));

    return missions;
  }

  Map<String, dynamic> _syncEntityTimeZone(
      {required Map<String, dynamic> entity, required DateTime baseDate}) {
    return {
      ...entity,
      'created_at': TimeUtils.syncTimeZone(
              baseDate: baseDate,
              targetDate: DateTime.parse(entity['created_at']))
          .toIso8601String()
    };
  }
}
