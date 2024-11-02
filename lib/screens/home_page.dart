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

  @override
  void initState() {
    super.initState();
    _loadMissionTimes();
  }

  void _loadMissionTimes() {
    setState(() {
      mission1Time = MissionService.getMissionTime(1);
      mission2Time = MissionService.getMissionTime(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        children: [
          if (mission1Time != null)
            ListTile(
              title: Text('미션시간 1 ($mission1Time)'),
              trailing: Checkbox(
                value: false,
                onChanged: null,
              ),
            ),
          if (mission2Time != null)
            ListTile(
              title: Text('미션시간 2 ($mission2Time)'),
              trailing: Checkbox(
                value: false,
                onChanged: null,
              ),
            ),
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
