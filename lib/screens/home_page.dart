import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/entities/current_participant.dart';
import 'package:notiyou/models/mission.dart';
import 'package:notiyou/screens/challenger_config_page.dart';
import 'package:notiyou/screens/signup_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/mission_history_service.dart';
import 'package:notiyou/services/participant_service.dart';

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
    final user = await AuthService.getUserSafe();
    if (user.userMetadata == null) {
      if (!mounted) return;
      context.go(SignupPage.routeName);
      return;
    }

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
      appBar: AppBar(title: Text('${_participant!.name}님의 Home')),
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
  final hasSupporter = supporter != null;

  return Container(
    color: hasSupporter ? Colors.green[100] : Colors.red[100],
    padding: const EdgeInsets.all(16.0),
    child: hasSupporter
        ? SizedBox(
            width: double.infinity,
            child: Text(
              '조력자 ${supporter.name}님과 함께 하고 있습니다.',
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    '아직 조력자가 설정되지 않았습니다',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '조력자가 초대를 수락하기 전까지는 혼자 미션을 수행하게 됩니다. 조력자와 함께 미션을 수행해보세요.',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  context.go(ChallengerConfigPage.routeName);
                },
                child: const Text('조력자 초대하러 가기'),
              ),
            ],
          ),
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
                onChanged: (bool? value) {
                  onToggleMissionComplete(mission.id);
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
  return Container(
      color: Colors.green[100],
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '도전자 ${challenger?.name}님과 함께 하고 있습니다.',
      ));
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
