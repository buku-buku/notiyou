import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_page.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  static const String routeName = '/config';

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  TimeOfDay? _mission1Time;
  TimeOfDay? _mission2Time;

  Future<void> _selectTime(BuildContext context, bool isFirstMission) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
              title: const Text('미션시간 1'),
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
              onPressed: _mission1Time != null || _mission2Time != null
                  ? () {
                      context.go(HomePage.routeName);
                    }
                  : null, // 최소 하나의 시간이 선택되어야 버튼 활성화
              child: const Text('설정 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
