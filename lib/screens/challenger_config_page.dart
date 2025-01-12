import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/models/registration_status.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/mission_config_service.dart';
import 'package:notiyou/widgets/notification_template_config.dart';
import 'package:notiyou/widgets/supporter_section.dart';

class ChallengerConfigPage extends StatefulWidget {
  static const String routeName = '/challenger/config';
  static const String onboardingRouteName = '/challenger/config_onboarding';

  final bool isFirstTime;

  const ChallengerConfigPage({
    super.key,
    this.isFirstTime = false,
  });

  @override
  State<ChallengerConfigPage> createState() => _ChallengerConfigPageState();
}

class _ChallengerConfigPageState extends State<ChallengerConfigPage> {
  TimeOfDay? _mission1Time;
  TimeOfDay? _mission2Time;
  int _selectedGracePeriod = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedTimes();
    _loadSavedGracePeriod();
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

  Future<void> _loadSavedGracePeriod() async {
    final int savedGracePeriod = await MissionConfigService.getGracePeriod();
    setState(() {
      _selectedGracePeriod = savedGracePeriod;
    });
  }

  Future<void> _saveTimes() async {
    // 시간이 변경되었는지 확인
    final bool hasTimeChanged =
        _mission1Time != await MissionConfigService.getMissionTime(1) ||
            _mission2Time != await MissionConfigService.getMissionTime(2) ||
            _selectedGracePeriod != await MissionConfigService.getGracePeriod();

    if (hasTimeChanged == false) {
      return;
    }

    await MissionConfigService.saveMissionTime(1, _mission1Time);
    await MissionConfigService.saveMissionTime(2, _mission2Time);
    await MissionConfigService.saveGracePeriod(_selectedGracePeriod);
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

  bool _isSubmittable() {
    return _mission1Time != null;
  }

  Future<void> _handleSubmit() async {
    if (_isSubmittable() == false) return;
    await _saveTimes();
    if (widget.isFirstTime) {
      AuthService.setRole(UserRole.challenger);
    }
    if (mounted) {
      context.go(HomePage.routeName);
    }
  }

  Future<void> _showGracePeriodExplanation() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                height: 1.6,
              ),
              children: [
                TextSpan(
                  text: '유예 시간',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '은 미션 시간 이후 미션을 완료하기까지 허용되는 추가 시간입니다.\n',
                ),
                TextSpan(
                  text: '예를 들어, 미션 시간이 오전 10시이고 ',
                  style: TextStyle(color: Color(0xFF424242)),
                ),
                TextSpan(
                  text: '유예 시간',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                TextSpan(
                  text:
                      '이 5분으로 설정된 경우, 오전 10시 5분까지 미션 완료를 기록하지 않으면 미션 실패로 간주하여 조력자에게 알림이 발송됩니다.',
                  style: TextStyle(color: Color(0xFF424242)),
                ),
              ],
            ),
          ),
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
                    TextSpan(text: '미션 시간 1 '),
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
              title: const Text('미션 시간 2'),
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
            ListTile(
              title: Row(
                children: [
                  const Text('유예 시간'),
                  IconButton(
                    icon: const Icon(
                      Icons.help_outline,
                      size: 20,
                    ),
                    onPressed: _showGracePeriodExplanation,
                  ),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<int>(
                  value: _selectedGracePeriod,
                  items: List.generate(13, (index) => index * 5)
                      .map((value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value 분'),
                          ))
                      .toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedGracePeriod = newValue ?? 0;
                    });
                  },
                ),
              ),
            ),
            const SupporterSection(),
            ElevatedButton(
              onPressed: _showNotificationTemplateModal,
              child: const Text('알림 메시지 설정'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmittable() ? _handleSubmit : null,
              child: const Text('설정 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
