import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/services/mission_config_service.dart';
import 'package:notiyou/widgets/notification_template_config.dart';
import 'package:notiyou/widgets/supporter_section.dart';

class ChallengerConfigPage extends StatefulWidget {
  static const String routeName = '/challenger/config';
  static const String onboardingRouteName = '/challenger/config_onboarding';

  const ChallengerConfigPage({
    super.key,
  });

  @override
  State<ChallengerConfigPage> createState() => _ChallengerConfigPageState();
}

class _ChallengerConfigPageState extends State<ChallengerConfigPage> {
  TimeOfDay? _mission1Time;
  TimeOfDay? _mission2Time;

  @override
  void initState() {
    super.initState();
    _loadSavedTimes();
  }

  Future<void> _loadSavedTimes() async {
    final results = await Future.wait([
      MissionConfigService.getMissionTime(1),
      MissionConfigService.getMissionTime(2),
    ]);
    setState(() {
      // 병렬 처리

      _mission1Time = results[0];
      _mission2Time = results[1];
    });
  }

  Future<void> _saveTimes() async {
    // 시간이 변경되었는지 확인
    final bool hasTimeChanged =
        _mission1Time != await MissionConfigService.getMissionTime(1) ||
            _mission2Time != await MissionConfigService.getMissionTime(2);

    if (hasTimeChanged == false) {
      return;
    }

    await MissionConfigService.saveMissionTime(1, _mission1Time);
    await MissionConfigService.saveMissionTime(2, _mission2Time);
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

  Future<void> _showNotificationTemplateModal() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const NotificationTemplateConfig(),
        );
      },
    );
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
                        fontSize: 12,
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
            const SupporterSection(),
            ElevatedButton(
              onPressed: _showNotificationTemplateModal,
              child: const Text('알림 메시지 설정'),
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
