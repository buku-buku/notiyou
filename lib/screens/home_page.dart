import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/models/mission.dart';
import 'config_page.dart';
import 'history_page.dart';
import 'login_page.dart';
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
                trailing: Checkbox(
                  value: mission.isCompleted,
                  onChanged: (bool? value) {
                    _toggleMissionComplete(mission.id);
                  },
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '히스토리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: '로그아웃',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.go(HistoryPage.routeName);
              break;
            case 2:
              context.go(ConfigPage.routeName);
              break;
            case 3:
              context.go(LoginPage.routeName);
              break;
          }
        },
      ),
    );
  }

  Future<void> _toggleMissionComplete(String missionId) async {
    final newState = await MissionService.toggleMissionComplete(missionId);
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
}
