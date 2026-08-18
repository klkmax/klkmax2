class WorkSession {
  final String id;
  final DateTime start;
  final DateTime? end;
  final bool isManual;
  final String? note;
  final bool isHoliday;
  final String shift;

  WorkSession({
    required this.id,
    required this.start,
    this.end,
    this.isManual = false,
    this.note,
    this.isHoliday = false,
    this.shift = 'Auto',
  });

  bool get isRunning => end == null;

  Duration get workedDuration {
    final endTime = end ?? DateTime.now();
    return endTime.difference(start);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start': start.toIso8601String(),
      'end': end?.toIso8601String(),
      'isManual': isManual,
      'note': note,
      'isHoliday': isHoliday,
      'shift': shift,
    };
  }

  factory WorkSession.fromMap(Map<String, dynamic> map) {
    return WorkSession(
      id: map['id'],
      start: DateTime.parse(map['start']),
      end: map['end'] != null ? DateTime.parse(map['end']) : null,
      isManual: map['isManual'] ?? false,
      note: map['note'],
      isHoliday: map['isHoliday'] ?? false,
      shift: map['shift'] ?? 'Auto',
    );
  }
}
