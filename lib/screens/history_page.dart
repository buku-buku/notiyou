import 'package:flutter/material.dart';
import 'package:notiyou/models/mission.dart';
import 'package:notiyou/utils/time_utils.dart';
import 'package:notiyou/widgets/mission_history_list_item.dart';
import 'package:notiyou/services/mission_history_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  static const String routeName = '/history';

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Map<String, List<Mission>> groupedMissions = {};

  @override
  void initState() {
    super.initState();
    _loadMissionHistories();
  }

  Future<void> _loadMissionHistories() async {
    var missions = await MissionHistoryService.getAllMissions();

    setState(() {
      groupedMissions = _groupMissionsByDate(missions);
    });
  }

  Map<String, List<Mission>> _groupMissionsByDate(List<Mission> missions) {
    final Map<String, List<Mission>> groupedMissions = {};

    for (var mission in missions) {
      final dateKey = TimeUtils.formatDateTime(
        date: mission.date,
        format: 'yyyy.MM.dd (E)',
      );

      if (groupedMissions.containsKey(dateKey)) {
        groupedMissions[dateKey]!.add(mission);
      } else {
        groupedMissions[dateKey] = [mission];
      }
    }

    return groupedMissions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미션 히스토리')),
      body: groupedMissions.isEmpty
          ? const Center(child: Text('아직 미션 히스토리가 없습니다.'))
          : ListView.builder(
              itemCount: groupedMissions.keys.length,
              itemBuilder: (context, index) {
                final dateKey = groupedMissions.keys.elementAt(index);
                final missions = groupedMissions[dateKey]!;

                return StyledGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateKey,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ...missions.map((mission) =>
                          MissionHistoryListItem(mission: mission)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class StyledGroup extends StatelessWidget {
  final Widget child;

  const StyledGroup({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.4,
          ),
        ),
      ),
      child: child,
    );
  }
}
