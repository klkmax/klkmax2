import 'package:hive_flutter/hive_flutter.dart';
import '../models/work_session.dart';
import '../models/user_settings.dart';
import '../models/note.dart';
import 'overtime_calculator.dart';

class StorageService {
  static const String _sessionsBox = 'sessions';
  static const String _notesBox = 'notes';
  static const String _settingsBox = 'settings';
  static const String _settingsKey = 'user_settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_sessionsBox);
    await Hive.openBox(_notesBox);
    await Hive.openBox(_settingsBox);
  }

  static Future<void> saveSession(WorkSession session) async {
    final box = Hive.box(_sessionsBox);
    await box.put(session.id, session.toMap());
  }

  static Future<void> deleteSession(String id) async {
    final box = Hive.box(_sessionsBox);
    await box.delete(id);
  }

  static List<WorkSession> getAllSessions() {
    final box = Hive.box(_sessionsBox);
    return box.values
        .map((e) => WorkSession.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.start.compareTo(a.start));
  }

  static List<WorkSession> getSessionsBetween(DateTime start, DateTime end) {
    return getAllSessions().where((s) {
      return s.start.isAfter(start.subtract(const Duration(seconds: 1))) &&
          s.start.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  static Future<void> saveNote(Note note) async {
    final box = Hive.box(_notesBox);
    await box.put(note.id, note.toMap());
  }

  static Future<void> deleteNote(String id) async {
    final box = Hive.box(_notesBox);
    await box.delete(id);
  }

  static List<Note> getAllNotes() {
    final box = Hive.box(_notesBox);
    return box.values
        .map((e) => Note.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<Note> getNotesForDay(DateTime day) {
    return getAllNotes().where((n) {
      if (n.reminderDate == null) return false;
      final d = n.reminderDate!;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  static Future<void> saveSettings(UserSettings settings) async {
    final box = Hive.box(_settingsBox);
    await box.put(_settingsKey, settings.toMap());
    OvertimeCalculator.overtimeRate = settings.overtimeRate;
  }

  static UserSettings getSettings() {
    final box = Hive.box(_settingsBox);
    final data = box.get(_settingsKey);
    if (data == null) return UserSettings();
    return UserSettings.fromMap(Map<String, dynamic>.from(data));
  }

  static Future<void> clearAllData() async {
    await Hive.box(_sessionsBox).clear();
    await Hive.box(_notesBox).clear();
  }
}
