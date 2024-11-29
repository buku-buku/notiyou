import 'package:flutter/material.dart';
import '../utils/time_utils.dart';
import '../widgets/mission_history_list_item.dart';
import '../models/mission_history.dart';
import '../services/mission_history_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  static const String routeName = '/history';

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Map<String, List<MissionHistory>> groupedMissionHistories = {};

  @override
  void initState() {
    super.initState();
    _loadMissionHistories();
  }

  Future<void> _loadMissionHistories() async {
    // TODO(민철): 아래 더미 데이터를 MissionHistoryService에서 사용할 수 있는 실제 유저 아이디로 변경해야 합니다.
    var missionHistories =
        await MissionHistoryService.getMissionHistoriesByUserId('1234');

    setState(() {
      groupedMissionHistories = _groupMissionHistoriesByDate(missionHistories);
    });
  }

  Map<String, List<MissionHistory>> _groupMissionHistoriesByDate(
      List<MissionHistory> missionHistories) {
    final Map<String, List<MissionHistory>> groupedMissionHistories = {};

    for (var history in missionHistories) {
      final dateKey = TimeUtils.formatDateTime(
        date: DateTime.parse(history.missionAt),
        format: 'yyyy-MM-dd (E)',
      );

      if (groupedMissionHistories.containsKey(dateKey)) {
        groupedMissionHistories[dateKey]!.add(history);
      } else {
        groupedMissionHistories[dateKey] = [history];
      }
    }
    return groupedMissionHistories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('히스토리')),
      body: groupedMissionHistories.isEmpty
          ? const Center(child: Text('미션 히스토리가 없습니다.'))
          : ListView.builder(
              itemCount: groupedMissionHistories.keys.length,
              itemBuilder: (context, index) {
                final dateKey = groupedMissionHistories.keys.elementAt(index);
                final histories = groupedMissionHistories[dateKey]!;

                return StyledGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateKey,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ...histories.map((history) =>
                          MissionHistoryListItem(missionHistory: history)),
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
