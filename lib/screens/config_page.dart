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
    final mission1String = MissionService.getMissionTime(1);
    final mission2String = MissionService.getMissionTime(2);

    print('저장된 미션1 시간: $mission1String');
    print('저장된 미션2 시간: $mission2String');

    setState(() {
      if (mission1String != null) {
        final parts = mission1String.split(':');
        _mission1Time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }

      if (mission2String != null) {
        final parts = mission2String.split(':');
        _mission2Time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    });
  }

  String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveTimes() async {
    if (_mission1Time != null) {
      await MissionService.saveMissionTime(1, _timeToString(_mission1Time!));
    } else {
      await MissionService.saveMissionTime(1, null);
    }

    if (_mission2Time != null) {
      await MissionService.saveMissionTime(2, _timeToString(_mission2Time!));
    } else {
      await MissionService.saveMissionTime(2, null);
    }
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
      print('선택된 시간: ${picked.format(context)}');
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
