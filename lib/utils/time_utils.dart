import 'package:flutter/material.dart';

class TimeUtils {
  // 시간 객체를 문자열로 변환
  static String stringifyTime(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }

  // 문자열을 시간 객체로 변환
  static TimeOfDay parseTime(String timeStr) {
    final hour = int.parse(timeStr.split(':')[0]);
    final minute = int.parse(timeStr.split(':')[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
}
