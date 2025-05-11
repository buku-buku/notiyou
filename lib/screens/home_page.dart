import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/entities/current_participant.dart';
import 'package:notiyou/models/mission.dart';
import 'package:notiyou/screens/challenger_config_page.dart';
import 'package:notiyou/services/mission_history_service.dart';
import 'package:notiyou/services/participant_service.dart';
import 'package:notiyou/widgets/partner_info_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Mission> _missions = [];
  CurrentParticipant? _participant;
  final _participantService = ParticipantService.getInstance();

  @override
  void initState() {
    super.initState();
    _initPageView();
  }

  Future<void> _initPageView() async {
    final [missions, participant] = await Future.wait([
      _loadMissions(),
      _participantService.getCurrentParticipant(),
    ]);

    if (!mounted) return;
    setState(() {
      _missions = missions as List<Mission>;
      _participant = participant as CurrentParticipant;
    });
  }

  Future<List<Mission>> _loadMissions() async {
    return await MissionHistoryService.getTodaysMissions();
  }

  Future<void> _toggleMissionComplete(int missionId) async {
    final newState =
        await MissionHistoryService.toggleMissionComplete(missionId);
    setState(() {
      final updatedMissions = _missions.map((mission) {
        if (mission.id == missionId) {
          return Mission(
            id: mission.id,
            time: mission.time,
            isCompleted: newState,
            completedAt: newState ? DateTime.now() : null,
            date: mission.date,
          );
        }
        return mission;
      }).toList();
      _missions = updatedMissions;
    });

    // 미션 상태 변경 후 만료 상태와 완료 시간 다시 로드
    _loadMissions();
  }

  @override
  Widget build(BuildContext context) {
    if (_participant == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_participant!.name}님의 미션'),
      ),
      body: ListView(
        children: [
          if (_participant!.isChallenger)
            buildChallengerView(
              context,
              _participant!.partner,
              _missions,
              _toggleMissionComplete,
            ),
          if (_participant!.isSupporter)
            buildSupporterView(
              context,
              _participant!.partner,
              _missions,
            ),
        ],
      ),
    );
  }
}

Widget buildSupporterAlertBannerForChallenger({
  required BuildContext context,
  required Partner? supporter,
}) {
  return PartnerInfoBanner(
    partner: supporter,
    isChallenger: true,
    onTap: () {
      context.go(ChallengerConfigPage.routeName);
    },
  );
}

Widget buildChallengerView(
  BuildContext context,
  Partner? supporter,
  List<Mission> missions,
  Future<void> Function(int) onToggleMissionComplete,
) {
  return Column(
    children: [
      buildSupporterAlertBannerForChallenger(
          context: context, supporter: supporter),
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
                '미션 시간 ${mission.id} (${mission.time.format(context)})',
                style: TextStyle(
                  color: mission.expired ? Colors.red : null,
                ),
              ),
              subtitle: mission.isCompleted && mission.completedAt != null
                  ? Text('완료 시간: ${mission.formattedCompletedTime ?? ''}')
                  : null,
              trailing: Checkbox(
                value: mission.isCompleted,
                onChanged: (bool? value) async {
                  if (mission.isCompleted) {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('주의'),
                        content: const Text('이미 완료 처리한 미션입니다.\n정말 되돌리겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('아니오'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('예'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      onToggleMissionComplete(mission.id);
                    }
                  } else {
                    onToggleMissionComplete(mission.id);
                  }
                },
              )),
        ],
      ],
      if (missions.isEmpty)
        const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '설정된 미션이 없습니다.\n설정 메뉴에서 미션 시간을 설정해주세요.',
                textAlign: TextAlign.center,
              )),
        ),
    ],
  );
}

Widget buildChallengerInfoBannerForSupporter({
  required BuildContext context,
  required Partner? challenger,
}) {
  return PartnerInfoBanner(
    partner: challenger,
    isChallenger: false,
  );
}

Widget buildSupporterView(
  BuildContext context,
  Partner? challenger,
  List<Mission> missions,
) {
  return Column(
    children: [
      buildChallengerInfoBannerForSupporter(
          context: context, challenger: challenger),
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
                '미션 시간 ${mission.id} (${mission.time.format(context)})',
                style: TextStyle(
                  color: mission.expired ? Colors.red : null,
                ),
              ),
              subtitle: mission.isCompleted && mission.completedAt != null
                  ? Text('완료 시간: ${mission.formattedCompletedTime ?? ''}')
                  : null,
              trailing: Text(
                mission.isCompleted ? '완료' : '미완료',
                style: TextStyle(
                  color: mission.isCompleted ? Colors.green : Colors.red,
                ),
              )),
        ],
      ],
      if (missions.isEmpty)
        const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '설정된 미션이 없습니다.\n설정 메뉴에서 미션 시간을 설정해주세요.',
                textAlign: TextAlign.center,
              )),
        ),
    ],
  );
}
