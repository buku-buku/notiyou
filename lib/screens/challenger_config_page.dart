import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/models/registration_status.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/mission_config_service.dart';
import 'package:notiyou/services/user_metadata_service.dart';
import 'package:notiyou/widgets/notification_template_config.dart';
import 'package:notiyou/widgets/supporter_section.dart';
import 'package:notiyou/widgets/back_button_app_bar.dart';

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
    DatePicker.showTime12hPicker(
      context,
      showTitleActions: true,
      onConfirm: (time) {
        setState(() {
          if (config == _mission1TimeConfig) {
            _mission1TimeConfig = _MissionTimeConfig(
              missionId: _mission1TimeConfig?.missionId,
              missionTime: TimeOfDay.fromDateTime(time),
            );
          } else {
            _mission2TimeConfig = _MissionTimeConfig(
              missionId: _mission2TimeConfig?.missionId,
              missionTime: TimeOfDay.fromDateTime(time),
            );
          }
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.ko,
    );
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
        final userId = await AuthService.getUserId();
        await UserMetadataService.setRole(userId, UserRole.challenger);
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
      appBar: AppBar(title: const Text('미션 설정')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            buildSettingButton(
              context: context,
              label: '알림 메시지 설정하기',
            ),
            const Spacer(),
            if (!widget.isFirstTime) const SupporterSection(),
            const Spacer(),
            buildSubmitButton(
              context: context,
              label: '설정 완료',
              isLoading: _isSubmitLoading,
              isEnabled: _isSubmittable() && !_isSubmitLoading,
              onSubmit: _handleSubmit,
            ),
            const SizedBox(height: 8),
            buildDeleteAccountButton(context),
          ],
        ),
      ),
    );
  }
}

Widget buildDeleteAccountButton(BuildContext context) {
  return TextButton(
    style: TextButton.styleFrom(
      foregroundColor: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      minimumSize: const Size(0, 32),
      tapTargetSize: MaterialTapTargetSize.padded,
    ),
    onPressed: () async {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('※주의', style: TextStyle(color: Colors.red)),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('정말 회원탈퇴 하시겠습니까?'),
                SizedBox(height: 8),
                Text(
                  '회원탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
      if (confirm == true) {
        try {
          await AuthService.deleteAccount();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('회원탈퇴가 완료되었습니다.'),
                duration: Duration(seconds: 2)),
          );
          context.go('/login');
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원탈퇴 중 오류가 발생했습니다: \n$e')),
          );
        }
      }
    },
    child: const Text('회원탈퇴', style: TextStyle(fontSize: 12)),
  );
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

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 4.0),
    child: OutlinedButton.icon(
      onPressed: () => showNotificationTemplateModal(),
      icon: const Icon(Icons.notifications_outlined, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        side: const BorderSide(color: Colors.purple),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
}

Widget buildSubmitButton({
  required BuildContext context,
  required String label,
  required bool isLoading,
  required bool isEnabled,
  required VoidCallback onSubmit,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 4.0),
    child: ElevatedButton(
      onPressed: isEnabled ? onSubmit : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        backgroundColor: isEnabled ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: isEnabled ? 2 : 0,
      ),
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
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
          : Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  );
}
