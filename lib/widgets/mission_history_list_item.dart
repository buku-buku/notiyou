import 'package:flutter/material.dart';
import '../models/mission_history.dart';

const incompleteText = '미완료';
const done = (color: Colors.green, icon: Icons.check_circle);
const notDone = (color: Colors.red, icon: Icons.cancel);

class MissionHistoryListItem extends StatelessWidget {
  final MissionHistory missionHistory;

  const MissionHistoryListItem({super.key, required this.missionHistory});

  @override
  Widget build(BuildContext context) {
    final isDone = missionHistory.doneAt != null;
    final doneAtText = isDone
        ? TimeOfDay.fromDateTime(DateTime.parse(missionHistory.doneAt!))
            .format(context)
        : incompleteText;

    final missionAtText =
        TimeOfDay.fromDateTime(DateTime.parse(missionHistory.missionAt))
            .format(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('미션 ${missionHistory.missionId}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 4),
              Text('설정 시간: $missionAtText'),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 16),
              const SizedBox(width: 4),
              Text('완료 시간: $doneAtText'),
            ],
          ),
        ],
      ),
      trailing: Icon(
        isDone ? done.icon : notDone.icon,
        color: isDone ? done.color : notDone.color,
      ),
    );
  }
}
