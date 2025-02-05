import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notiyou/models/mission.dart';

void main() {
  group('Mission.copyWith()', () {
    late Mission mission;

    setUp(() {
      mission = Mission(
        id: 1,
        time: const TimeOfDay(hour: 9, minute: 0),
        isCompleted: false,
        completedAt: null,
        date: DateTime(2024, 3, 20),
      );
    });

    test('파라미터를 전달하지 않으면, 원래 값이 유지된다', () {
      final copied = mission.copyWith();

      expect(copied.id, mission.id);
      expect(copied.time, mission.time);
      expect(copied.isCompleted, mission.isCompleted);
      expect(copied.completedAt, mission.completedAt);
      expect(copied.date, mission.date);
    });

    test('미션을 미완료 상태로 변경하면, completedAt은 값을 전달하든 전달하지 않든 항상 null이 된다', () {
      final completed = mission.copyWith(
        isCompleted: true,
        completedAt: DateTime(2024, 3, 20),
      );

      final uncompleted = completed.copyWith(
        isCompleted: false,
      );

      expect(uncompleted.isCompleted, false);
      expect(uncompleted.completedAt, null);

      final uncompleted2 = completed.copyWith(
        isCompleted: false,
        completedAt: DateTime(2024, 3, 21),
      );

      expect(uncompleted2.isCompleted, false);
      expect(uncompleted2.completedAt, null);

      final uncompleted3 = completed.copyWith(
        isCompleted: false,
        completedAt: null,
      );

      expect(uncompleted3.isCompleted, false);
      expect(uncompleted3.completedAt, null);
    });
  });
}
