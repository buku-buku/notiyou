import 'package:flutter/material.dart';
import 'package:notiyou/models/mission.dart';
import 'package:notiyou/services/notification_service.dart';
import '../services/mission_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Mission> missions = [];

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    final todaysMissions = await MissionService.getTodaysMissions();
    setState(() {
      missions = todaysMissions;
    });
  }

  Future<void> _toggleMissionComplete(String missionId) async {
    final newState = await MissionService.toggleMissionComplete(missionId);

    if (newState) {
      final result = await NotificationService.sendCompleteMessageToSupporter();

      if (!mounted) return;

      String message;
      Color backgroundColor;

      switch (result) {
        case NotificationResult.success:
          message = '메시지를 성공적으로 전송했습니다';
          backgroundColor = Colors.green;
        case NotificationResult.error:
          message = '메시지 전송에 실패했습니다';
          backgroundColor = Colors.red;
        case NotificationResult.noReceiver:
          message = '등록된 조력자가 없습니다';
          backgroundColor = Colors.orange;
        case NotificationResult.partialFailure:
          message = '일부 메시지 전송에 실패했습니다';
          backgroundColor = Colors.orange;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2), // 표시 시간 조절 가능
          behavior: SnackBarBehavior.floating, // 플로팅 스타일
          margin: const EdgeInsets.all(16), // 여백 추가
        ),
      );
    }

    setState(() {
      final updatedMissions = missions.map((mission) {
        if (mission.id == missionId) {
          return Mission(
            id: mission.id,
            missionNumber: mission.missionNumber,
            time: mission.time,
            isCompleted: newState,
            completedAt: newState ? DateTime.now() : null,
            date: mission.date,
          );
        }
        return mission;
      }).toList();
      missions = updatedMissions;
    });

    // 미션 상태 변경 후 만료 상태와 완료 시간 다시 로드
    _loadMissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        children: [
          if (missions.isNotEmpty) ...[
            for (var mission in missions) ...[
              if (mission.expired)
                Container(
                  color: Colors.red[100],
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    '⚠️ 미션이 완료되지 않았습니다!!!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ListTile(
                title: Text(
                  '미션시간 ${mission.id} (${mission.time.format(context)})',
                  style: TextStyle(
                    color: mission.expired ? Colors.red : null,
                  ),
                ),
                subtitle: mission.isCompleted && mission.completedAt != null
                    ? Text('완료 시간: ${mission.formattedCompletedTime ?? ''}')
                    : null,
                trailing: ElevatedButton(
                  onPressed: () => _toggleMissionComplete(mission.id),
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        mission.isCompleted ? Colors.green : Colors.grey[600],
                    backgroundColor: Colors.white,
                    elevation: 0,
                    side: BorderSide(
                      color: mission.isCompleted
                          ? Colors.green
                          : Colors.grey[400]!,
                      width: 1,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                  ),
                  child: Text(
                    mission.isCompleted ? '완료' : '미완료',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
          if (missions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '설정된 미션이 없습니다.\n설정 메뉴에서 미션 시간을 설정해주세요.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
