class Mission {
  final String id;
  final String time;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime date;

  Mission({
    required this.id,
    required this.time,
    required this.isCompleted,
    this.completedAt,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'date': date.toIso8601String(),
      };

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
        id: json['id'],
        time: json['time'],
        isCompleted: json['isCompleted'],
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        date: DateTime.parse(json['date']),
      );

  bool get expired {
    if (isCompleted) return false;
    final now = DateTime.now();
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(time.split(':')[0]),
      int.parse(time.split(':')[1]),
    ).isBefore(now);
  }

  String? get formattedCompletedTime {
    if (completedAt == null) return null;
    return '${completedAt!.hour.toString().padLeft(2, '0')}:${completedAt!.minute.toString().padLeft(2, '0')}';
  }
}
