import 'package:flutter/material.dart';
import 'package:notiyou/models/mission.dart';
import 'package:notiyou/repositories/mission_history_repository_interface.dart';
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
/// TODO(무호): supabas의 테이블 명칭을 상수로 관리한다.
class MissionHistoryRepositoryRemote implements MissionHistoryRepository {
  @override
  Future<Mission?> findMissionById(String id) async {
    final entity =
        await SupabaseService.client.from('mission_history').select('''
          id,
          done_at,
          created_at,
          mission_at,
          challenger_mission_time (
            id,
            mission_number,
            challenger_id
          )
        ''').eq('id', id).single();

    return Mission.fromMissionHistoryEntity(entity);
  }

  @override
  Future<void> init() async {
    // 원격 저장소는 초기화가 필요 없음
    return;
  }

  @override
  Future<void> removeTodayMission(int missionNumber) async {
    final today = DateTime.now();

    await SupabaseService.client
        .from('mission_history')
        .delete()
        .eq('challenger_mission_time.mission_number', missionNumber)
        .gte('created_at', today.toUtc().toIso8601String());
  }

  @override
  Future<void> updateMission(Mission mission) async {
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
  Future<void> createTodayMission(int missionNumber) async {
    final newMission = await SupabaseService.client
        .from('challenger_mission_time')
        .select('id, mission_at')
        .eq('mission_number', missionNumber)
        .single();

    await SupabaseService.client.from('mission_history').insert({
      'mission_id': newMission['id'],
      'mission_at': newMission['mission_at'],
    });
  }

  @override
  Future<bool> hasTodayMission(int missionNumber) async {
    final missions = await findMissions(DateTime.now());
    return missions.any((e) => e.missionNumber == missionNumber);
  }

  @override
  // TODO: updateMission 메서드에서 처리
  Future<void> updateTodayMissionTime(int missionNumber, TimeOfDay time) async {
    final mission = await SupabaseService.client
        .from('challenger_mission_time')
        .select('id')
        .eq('mission_number', missionNumber)
        .single();

    await SupabaseService.client.from('mission_history').update({
      'mission_at': TimeUtils.stringifyTime(time),
    }).eq('mission_id', mission['id']);
  }

  @override
  Future<List<Mission>> findMissions(DateTime date) async {
    final today = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final missionHistoryEntities = await SupabaseService.client
        .from('mission_history')
        .select('''
          id,
          done_at,
          created_at,
          mission_at,
          challenger_mission_time (
            id,
            mission_number,
            challenger_id
          )
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
