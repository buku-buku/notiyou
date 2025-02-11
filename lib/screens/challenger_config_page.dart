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

class _MissionTimeConfig {
  int? missionId;
  TimeOfDay? missionTime;

  _MissionTimeConfig({required this.missionId, required this.missionTime});
}

class _ChallengerConfigPageState extends State<ChallengerConfigPage> {
  _MissionTimeConfig? _mission1TimeConfig;
  _MissionTimeConfig? _mission2TimeConfig;
  int _selectedGracePeriod = 0;
  bool _isSubmitLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedTimes();
    _loadSavedGracePeriod();
  }

  Future<void> _loadSavedTimes() async {
    try {
      final results = await MissionConfigService.getMissionTimes();
      setState(() {
        for (int i = 0; i < results.length; i++) {
          if (i == 0) {
            _mission1TimeConfig = _MissionTimeConfig(
              missionId: results[i]!.id,
              missionTime: results[i]!.missionAt,
            );
          } else if (i == 1) {
            _mission2TimeConfig = _MissionTimeConfig(
              missionId: results[i]!.id,
              missionTime: results[i]!.missionAt,
            );
          }
        }
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('미션 시간을 불러오는 중 오류가 발생했습니다. Error: ${error.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _loadSavedGracePeriod() async {
    final int savedGracePeriod = await MissionConfigService.getGracePeriod();
    setState(() {
      _selectedGracePeriod = savedGracePeriod;
    });
  }

  Future<void> _saveTimes() async {
    final mission1TimeConfig = _mission1TimeConfig;
    final mission2TimeConfig = _mission2TimeConfig;

    if (mission1TimeConfig?.missionTime != null) {
      await MissionConfigService.saveMissionTime(
          mission1TimeConfig!.missionTime!, mission1TimeConfig.missionId);
    } else if (mission1TimeConfig != null &&
        mission1TimeConfig.missionId != null) {
      await MissionConfigService.clearMissionTime(
        missionId: mission1TimeConfig.missionId!,
      );
    }
    if (mission2TimeConfig?.missionTime != null) {
      await MissionConfigService.saveMissionTime(
          mission2TimeConfig!.missionTime!, mission2TimeConfig.missionId);
    } else if (mission2TimeConfig != null &&
        mission2TimeConfig.missionId != null) {
      await MissionConfigService.clearMissionTime(
        missionId: mission2TimeConfig.missionId!,
      );
    }

    await MissionConfigService.saveGracePeriod(_selectedGracePeriod);
  }

  Future<void> _selectTime(
      BuildContext context, _MissionTimeConfig? config) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: config?.missionTime ?? TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        if (config == _mission1TimeConfig) {
          _mission1TimeConfig = _MissionTimeConfig(
            missionId: _mission1TimeConfig?.missionId,
            missionTime: selectedTime,
          );
        } else {
          _mission2TimeConfig = _MissionTimeConfig(
            missionId: _mission2TimeConfig?.missionId,
            missionTime: selectedTime,
          );
        }
      });
    }
  }

  bool _isSubmittable() {
    return _mission1TimeConfig != null;
  }

  Future<void> _handleSubmit() async {
    try {
      if (_isSubmittable() == false) return;
      setState(() => _isSubmitLoading = true);
      await _saveTimes();
      if (widget.isFirstTime) {
        AuthService.setRole(UserRole.challenger);
      }
      if (mounted) {
        context.go(HomePage.routeName);
      }
      setState(() => _isSubmitLoading = false);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('설정을 저장하는 중 오류가 발생했습니다. Error: ${error.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Config')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildMissionTimeField(
              context: context,
              label: '미션 시간 1',
              required: true,
              value: _mission1TimeConfig?.missionTime,
              onSelectTime: (context) =>
                  _selectTime(context, _mission1TimeConfig),
              onReset: () => setState(() => _mission1TimeConfig = null),
            ),
            buildMissionTimeField(
              context: context,
              label: '미션 시간 2',
              value: _mission2TimeConfig?.missionTime,
              onSelectTime: (context) =>
                  _selectTime(context, _mission2TimeConfig),
              onReset: () => setState(() => _mission2TimeConfig = null),
            ),
            buildGracePeriodField(
              context: context,
              value: _selectedGracePeriod,
              onChanged: (newValue) => setState(() {
                _selectedGracePeriod = newValue ?? 0;
              }),
            ),
            if (!widget.isFirstTime) const SupporterSection(),
            buildSettingButton(
              context: context,
              label: '알림 메시지 설정',
            ),
            const SizedBox(height: 20),
            buildSubmitButton(
              context: context,
              label: '설정 완료',
              isLoading: _isSubmitLoading,
              isEnabled: _isSubmittable() && !_isSubmitLoading,
              onSubmit: _handleSubmit,
            )
          ],
        ),
      ),
    );
  }
}

Widget buildMissionTimeField({
  required BuildContext context,
  required String label,
  required TimeOfDay? value,
  required Function(BuildContext) onSelectTime,
  bool required = false,
  VoidCallback? onReset,
}) {
  return ListTile(
    title: Text.rich(
      TextSpan(
        children: [
          TextSpan(text: label),
          if (required)
            const TextSpan(
              text: ' (필수 선택)',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
        ],
      ),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onSelectTime(context),
          child: Text(
            value?.format(context) ?? '시간 선택',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        if (value != null && onReset != null)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: onReset,
          ),
      ],
    ),
  );
}

Widget buildGracePeriodField({
  required BuildContext context,
  required int value,
  required Function(int?) onChanged,
}) {
  Future<void> showGracePeriodExplanation(BuildContext context) async {
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

  return ListTile(
    title: Row(
      children: [
        const Text('유예 시간'),
        IconButton(
          icon: const Icon(Icons.help_outline, size: 20),
          onPressed: () => showGracePeriodExplanation(context),
        ),
      ],
    ),
    trailing: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<int>(
        value: value,
        items: List.generate(13, (index) => index * 5)
            .map((value) => DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value 분'),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

Widget buildSettingButton({
  required BuildContext context,
  required String label,
}) {
  Future<void> showNotificationTemplateModal() async {
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

  return ElevatedButton(
    onPressed: () => showNotificationTemplateModal(),
    child: Text(label),
  );
}

Widget buildSubmitButton({
  required BuildContext context,
  required String label,
  required bool isLoading,
  required bool isEnabled,
  required VoidCallback onSubmit,
}) {
  return ElevatedButton(
    onPressed: isEnabled ? onSubmit : null,
    child: isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: 10),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ],
          )
        : Text(label),
  );
}
