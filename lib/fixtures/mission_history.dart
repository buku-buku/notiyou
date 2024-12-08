// 🚨 fixtures 폴더는 supabase에서 데이터를 가져오는 것이 완성되면 삭제합니다. 개발 편의를 위해 작성된 임시 데이터입니다.

import 'package:notiyou/models/mission_history.dart';

final baseDate = DateTime.parse('2024-11-22 13:00:00');
const missionCountOnDay = 2;
const missionInterval = (12 ~/ missionCountOnDay);

List<MissionHistory> moreData = List.generate(
  12,
  (index) {
    final dayDelta = index ~/ missionCountOnDay;

    final missionTime = baseDate.add(
      Duration(
        days: dayDelta,
        hours: (index % missionCountOnDay) * missionInterval,
      ),
    );
    final doneTime = missionTime.add(const Duration(minutes: -3));
    final createTime = doneTime.add(const Duration(minutes: -3));

    return (
      id: index + 1,
      missionId: index + 1,
      missionAt: missionTime.toString(),
      doneAt: index.isEven ? doneTime.toString() : null,
      createdAt: createTime.toString(),
    );
  },
);

List<MissionHistory> missionHistoriesFixture = [
  ...moreData,
];
