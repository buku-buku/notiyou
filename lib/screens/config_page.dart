import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_page.dart';
import '../services/mission_service.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  static const String routeName = '/config';

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  TimeOfDay? _mission1Time;
  TimeOfDay? _mission2Time;

  @override
  void initState() {
    super.initState();
    _loadSavedTimes();
  }

  Future<void> _loadSavedTimes() async {
    setState(() {
      _mission1Time = MissionService.getMissionTime(1);
      _mission2Time = MissionService.getMissionTime(2);
    });
  }

  Future<void> _saveTimes() async {
    // 시간이 변경되었는지 확인
    final bool hasTimeChanged =
        _mission1Time != MissionService.getMissionTime(1) ||
            _mission2Time != MissionService.getMissionTime(2);

    final hasTodayMissions = await MissionService.hasTodayMissions();

    bool? applyToToday;
    if (hasTimeChanged && hasTodayMissions && context.mounted) {
      final BuildContext currentContext = context;
      applyToToday = await showDialog<bool>(
        context: currentContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('미션 시간 변경'),
            content: const Text('변경된 시간을 오늘의 미션에도 적용하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('아니오'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('예'),
              ),
            ],
          );
        },
      );
    }

    await MissionService.saveMissionTime(1, _mission1Time,
        isUpdateTodayMission: applyToToday == true);
    await MissionService.saveMissionTime(2, _mission2Time,
        isUpdateTodayMission: applyToToday == true);
  }

  Future<void> _selectTime(BuildContext context, bool isFirstMission) async {
    final initialTime = isFirstMission
        ? _mission1Time ?? TimeOfDay.now()
        : _mission2Time ?? TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isFirstMission) {
          _mission1Time = picked;
        } else {
          _mission2Time = picked;
        }
      });
    }
  }

  void _resetTime(bool isFirstMission) {
    setState(() {
      if (isFirstMission) {
        _mission1Time = null;
      } else {
        _mission2Time = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Config')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '미션시간 1 '),
                    TextSpan(
                      text: '(필수 선택)',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12, // 더 작은 폰트 사이즈
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _selectTime(context, true),
                    child: Text(
                      _mission1Time?.format(context) ?? '시간 선택',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (_mission1Time != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _resetTime(true),
                    ),
                ],
              ),
            ),
            ListTile(
              title: const Text('미션시간 2'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _selectTime(context, false),
                    child: Text(
                      _mission2Time?.format(context) ?? '시간 선택',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (_mission2Time != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _resetTime(false),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 카카오톡 친구 목록 확인하기 기능 연결 예정
              },
              child: const Text('조력자 선택'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _mission1Time != null
                  ? () async {
                      await _saveTimes();
                      if (context.mounted) {
                        context.go(HomePage.routeName);
                      }
                    }
                  : null,
              child: const Text('설정 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
