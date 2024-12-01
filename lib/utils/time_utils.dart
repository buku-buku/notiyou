import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  static bool isDateString(String dateStr) {
    return DateTime.tryParse(dateStr) != null;
  }

  // 날짜 문자열 파싱
  static DateTime parseDate(String dateStr) {
    return DateTime.parse(dateStr);
  }

  // 날짜 문자열 생성
  static String stringifyDate(DateTime date) {
    return date.toIso8601String();
  }

  /// 년월일만 포함하는 날짜 문자열 생성
  static String stringifyYearMonthDay(DateTime date) {
    return DateTime(date.year, date.month, date.day).toIso8601String();
  }

  static String formatDateTime({
    required DateTime date,
    required String format,
  }) {
    return DateFormat(format, 'ko_KR').format(date);
  }

  static DateTime syncTimeZone(
      {required DateTime baseDate, required DateTime targetDate}) {
    return targetDate.add(baseDate.timeZoneOffset);
  }
}
