import '../models/user_settings.dart';
import 'storage_service.dart';

enum ShiftType { diurno, vespertino, nocturno, auto }

class OvertimeResult {
  final Duration normalHours;
  final Duration overtimeHours;
  final double overtimeMoney;
  final bool exceedsWeeklyLimit;
  final Duration totalWorked;
  final String shiftUsed;

  OvertimeResult({
    required this.normalHours,
    required this.overtimeHours,
    required this.overtimeMoney,
    required this.exceedsWeeklyLimit,
    required this.totalWorked,
    this.shiftUsed = '',
  });
}

class OvertimeCalculator {
  static double overtimeRate = 210.49;
  static const int maxWeeklyHours = 44;

  static OvertimeResult calculate({
    required DateTime start,
    required DateTime end,
    bool isHoliday = false,
    ShiftType shift = ShiftType.auto,
    double? customRate,
  }) {
    final rate = customRate ?? overtimeRate;
    final settings = StorageService.getSettings();

    if (isHoliday) {
      final total = end.difference(start);
      return OvertimeResult(
        normalHours: Duration.zero,
        overtimeHours: total,
        overtimeMoney: (total.inMinutes / 60.0) * rate,
        exceedsWeeklyLimit: false,
        totalWorked: total,
        shiftUsed: 'Feriado',
      );
    }

    String shiftName;
    DateTime normalStart;
    DateTime normalEnd;

    final chosenShift = shift == ShiftType.auto
        ? _detectShift(start, settings)
        : shift;

    switch (chosenShift) {
      case ShiftType.diurno:
        shiftName = 'Diurno';
        normalStart = _parseTime(start, settings.diurnoStart);
        normalEnd = _parseTime(start, settings.diurnoEnd);
        break;
      case ShiftType.vespertino:
        shiftName = 'Vespertino';
        normalStart = _parseTime(start, settings.vespertinoStart);
        normalEnd = _parseTime(start, settings.vespertinoEnd);
        break;
      case ShiftType.nocturno:
        shiftName = 'Nocturno';
        normalStart = _parseTime(start, settings.nocturnoStart);
        normalEnd = _parseTime(start, settings.nocturnoEnd);
        if (normalEnd.isBefore(normalStart) || normalEnd.isAtSameMomentAs(normalStart)) {
          normalEnd = normalEnd.add(const Duration(days: 1));
        }
        break;
      default:
        shiftName = 'Diurno';
        normalStart = _parseTime(start, settings.diurnoStart);
        normalEnd = _parseTime(start, settings.diurnoEnd);
    }

    Duration normal = Duration.zero;
    Duration overtime = Duration.zero;

    if (end.isBefore(normalStart)) {
      overtime = end.difference(start);
    } else if (start.isAfter(normalEnd) || start.isAtSameMomentAs(normalEnd)) {
      overtime = end.difference(start);
    } else {
      final effectiveStart = start.isBefore(normalStart) ? normalStart : start;
      final effectiveEnd = end.isAfter(normalEnd) ? normalEnd : end;
      normal = effectiveEnd.difference(effectiveStart);
      if (start.isBefore(normalStart)) {
        overtime += normalStart.difference(start);
      }
      if (end.isAfter(normalEnd)) {
        overtime += end.difference(normalEnd);
      }
    }

    final total = normal + overtime;
    final money = (overtime.inMinutes / 60.0) * rate;

    return OvertimeResult(
      normalHours: normal,
      overtimeHours: overtime,
      overtimeMoney: money,
      exceedsWeeklyLimit: false,
      totalWorked: total,
      shiftUsed: shiftName,
    );
  }

  static ShiftType _detectShift(DateTime start, UserSettings settings) {
    final hour = start.hour + start.minute / 60.0;
    final diurnoStart = _timeToDouble(settings.diurnoStart);
    final diurnoEnd = _timeToDouble(settings.diurnoEnd);
    final vespertinoStart = _timeToDouble(settings.vespertinoStart);
    final vespertinoEnd = _timeToDouble(settings.vespertinoEnd);

    if (hour >= diurnoStart && hour < diurnoEnd) return ShiftType.diurno;
    if (hour >= vespertinoStart && hour < vespertinoEnd) return ShiftType.vespertino;
    return ShiftType.nocturno;
  }

  static DateTime _parseTime(DateTime day, String timeStr) {
    final parts = timeStr.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return DateTime(day.year, day.month, day.day, h, m);
  }

  static double _timeToDouble(String timeStr) {
    final parts = timeStr.split(':');
    return int.parse(parts[0]) + int.parse(parts[1]) / 60.0;
  }

  static String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  static String formatTime12h(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
