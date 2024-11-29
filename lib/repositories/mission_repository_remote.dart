import 'package:flutter/material.dart';
import 'package:notiyou/models/mission.dart';
import 'package:notiyou/repositories/mission_repository_interface.dart';
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

class MissionRepositoryRemote implements MissionRepository {
  @override
  Future<void> clearAllMissions() async {
    // 모든 미션 기록 삭제
    await SupabaseService.client.from('mission_history').delete().neq('id', '');
  }

  @override
  Future<Mission?> findMissionById(DateTime date, String id) async {
    final today = DateTime(date.year, date.month, date.day);
    final tomorrow = today.add(const Duration(days: 1));

    final results = await SupabaseService.client
        .from('mission_history')
        .select('''
          id,
          done_at,
          created_at,
          missions (
            id,
            mission_at,
            mission_number,
            user_id
          )
        ''')
        .eq('id', id)
        .lt('created_at', tomorrow.toUtc().toIso8601String())
        .single();

    final syncedEntity = _syncEntityTimeZone(entity: results, baseDate: date);
    return Mission.fromMissionHistoryEntity(syncedEntity);
  }

  @override
  Future<Mission?> findMissionByMissionNumber(
      DateTime date, int missionNumber) async {
    final today = DateTime(date.year, date.month, date.day);
    final tomorrow = today.add(const Duration(days: 1));

    final results = await SupabaseService.client
        .from('mission_history')
        .select('''
          id,
          done_at,
          created_at,
          missions (
            id,
            mission_at,
            mission_number,
            user_id
          )
        ''')
        .eq('missions.mission_number', missionNumber)
        .lt('created_at', tomorrow.toUtc().toIso8601String())
        .single();

    final syncedEntity = _syncEntityTimeZone(entity: results, baseDate: date);
    return Mission.fromMissionHistoryEntity(syncedEntity);
  }

  @override
  Future<void> init() async {
    // 원격 저장소는 초기화가 필요 없음
    return;
  }

  @override
  Future<void> removeMissionById(DateTime date, String id) async {
    await SupabaseService.client
        .from('mission_history')
        .delete()
        .eq('missions.id', id);
  }

  @override
  Future<void> removeMissionsBefore(DateTime date) async {
    final targetDate = DateTime(date.year, date.month, date.day);

    await SupabaseService.client
        .from('mission_history')
        .delete()
        .lt('created_at', targetDate.toUtc().toIso8601String());
  }

  @override
  Future<void> removeMissionsFrom(DateTime date) async {
    final targetDate = DateTime(date.year, date.month, date.day);

    await SupabaseService.client
        .from('mission_history')
        .delete()
        .gte('created_at', targetDate.toUtc().toIso8601String());
  }

  @override
  Future<void> removeTodayMission(int missionNumber) async {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    await SupabaseService.client
        .from('mission_history')
        .delete()
        .eq('missions.mission_number', missionNumber)
        .lt('created_at', tomorrow.toUtc().toIso8601String());
  }

  @override
  Future<void> updateMission(DateTime date, Mission mission) async {
    if (mission.completedAt == null) {
      await SupabaseService.client.from('mission_history').update({
        'done_at': null,
      }).eq('id', mission.id);
    } else {
      await SupabaseService.client.from('mission_history').update({
        'done_at': mission.completedAt!.toUtc().toIso8601String(),
      }).eq('id', mission.id);
    }
  }

  @override
  // 현재 테이블 구조로는 오늘의 미션 시간은 언제나 mission_time에 동기화되어 관리 됨.
  // 따라서 해당 메서드는 구현할 필요가 없음.
  Future<void> updateTodayMissionTime(int missionNumber, TimeOfDay time) async {
    return Future.value();
  }

  @override
  Future<List<Mission>> findMissions(DateTime date,
      {bool createIfEmpty = false}) async {
    final today = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final missionHistoryEntities = await SupabaseService.client
        .from('mission_history')
        .select('''
          id,
          done_at,
          created_at,
          missions (
            id,
            mission_at,
            mission_number,
            user_id
          )
        ''')
        .gte('created_at', yesterday.toUtc().toIso8601String())
        .lt('created_at', tomorrow.toUtc().toIso8601String())
        .order('missions(mission_at)', ascending: true);

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
