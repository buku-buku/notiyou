import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  String? mission1Time;
  String? mission2Time;
  bool mission1Completed = false;
  bool mission2Completed = false;
  bool mission1Expired = false;
  bool mission2Expired = false;
  String? mission1CompletedAt;
  String? mission2CompletedAt;

  @override
  void initState() {
    super.initState();
    _loadMissionTimes();
    _checkMissionStatus();
  }

  void _loadMissionTimes() {
    setState(() {
      mission1Time = MissionService.getMissionTime(1);
      mission2Time = MissionService.getMissionTime(2);
      mission1Completed = MissionService.isMissionCompleted(1);
      mission2Completed = MissionService.isMissionCompleted(2);
      mission1CompletedAt = MissionService.getMissionCompletedAt(1);
      mission2CompletedAt = MissionService.getMissionCompletedAt(2);
    });
  }

  void _checkMissionStatus() {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    setState(() {
      if (mission1Time != null) {
        final parts = mission1Time!.split(':');
        final missionMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        mission1Expired = currentMinutes > missionMinutes && !mission1Completed;
        print('mission1Expired: $mission1Expired');
      }

      if (mission2Time != null) {
        final parts = mission2Time!.split(':');
        final missionMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        mission2Expired = currentMinutes > missionMinutes && !mission2Completed;
        print('mission2Expired: $mission2Expired');
      }
    });
  }

  Future<void> _toggleMissionComplete(int missionNumber) async {
    final newState = await MissionService.toggleMissionComplete(missionNumber);
    setState(() {
      if (missionNumber == 1) {
        mission1Completed = newState;
      } else {
        mission2Completed = newState;
      }
    });

    // 미션 상태 변경 후 만료 상태와 완료 시간 다시 로드
    _checkMissionStatus();
    _loadMissionTimes(); // 완료 시간 업데이트를 위해 추가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        children: [
          if (mission1Time != null) ...[
            if (mission1Expired)
              Container(
                color: Colors.red[100],
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  '⚠️ 미션1이 완료되지 않았습니다!!!',
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
                '미션시간 1 ($mission1Time)',
                style: TextStyle(
                  color: mission1Expired ? Colors.red : null,
                ),
              ),
              subtitle: mission1Completed && mission1CompletedAt != null
                  ? Text('완료 시간: $mission1CompletedAt')
                  : null,
              trailing: Checkbox(
                value: mission1Completed,
                onChanged: (bool? value) {
                  _toggleMissionComplete(1);
                },
              ),
            ),
          ],
          if (mission2Time != null) ...[
            if (mission2Expired)
              Container(
                color: Colors.red[100],
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  '⚠️ 미션2가 완료되지 않았습니다!!!',
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
                '미션시간 2 ($mission2Time)',
                style: TextStyle(
                  color: mission2Expired ? Colors.red : null,
                ),
              ),
              subtitle: mission2Completed && mission2CompletedAt != null
                  ? Text('완료 시간: $mission2CompletedAt')
                  : null,
              trailing: Checkbox(
                value: mission2Completed,
                onChanged: (bool? value) {
                  _toggleMissionComplete(2);
                },
              ),
            ),
          ],
          if (mission1Time == null && mission2Time == null)
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
}
