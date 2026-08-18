import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/work_session.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../services/overtime_calculator.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  List<WorkSession> _sessionsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return StorageService.getSessionsBetween(start, end).where((s) => s.end != null).toList();
  }

  List<Note> _notesForDay(DateTime day) {
    return StorageService.getNotesForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _sessionsForDay(_selectedDay);
    final notes = _notesForDay(_selectedDay);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _format,
            startingDayOfWeek: StartingDayOfWeek.monday,
            locale: 'es_ES',
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onFormatChanged: (f) => setState(() => _format = f),
            onPageChanged: (f) => _focusedDay = f,
            eventLoader: (day) {
              final s = _sessionsForDay(day);
              final n = _notesForDay(day);
              return [...s, ...n];
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: AppTheme.neonOrange),
              todayDecoration: BoxDecoration(
                color: AppTheme.neonCyan.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppTheme.neonOrange,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppTheme.electricMagenta,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              titleTextStyle: TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold, fontSize: 17),
              formatButtonTextStyle: TextStyle(color: AppTheme.neonOrange),
              leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.neonCyan),
              rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.neonCyan),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white54),
              weekendStyle: TextStyle(color: AppTheme.neonOrange),
            ),
          ),
          const Divider(color: Colors.white12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('EEEE d MMMM yyyy', 'es').format(_selectedDay),
                style: const TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          Expanded(
            child: sessions.isEmpty && notes.isEmpty
                ? const Center(
                    child: Text('Sin registros este día', style: TextStyle(color: Colors.white38)),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...sessions.map((s) {
                        final result = OvertimeCalculator.calculate(
                          start: s.start,
                          end: s.end!,
                          isHoliday: s.isHoliday,
                        );
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: AppTheme.premiumCard(borderColor: AppTheme.neonOrange.withOpacity(0.35)),
                          child: ListTile(
                            leading: const Icon(Icons.access_time, color: AppTheme.neonOrange),
                            title: Text(
                              '${OvertimeCalculator.formatTime12h(s.start)} – ${OvertimeCalculator.formatTime12h(s.end!)}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'Extra: ${OvertimeCalculator.formatDuration(result.overtimeHours)}  •  \$${result.overtimeMoney.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                          ),
                        );
                      }),
                      ...notes.map((n) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: AppTheme.premiumCard(borderColor: AppTheme.neonCyan.withOpacity(0.35)),
                          child: ListTile(
                            leading: Icon(
                              n.isCompleted ? Icons.check_circle : Icons.note_alt_outlined,
                              color: n.isCompleted ? Colors.green : AppTheme.neonCyan,
                            ),
                            title: Text(n.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            subtitle: n.content.isNotEmpty
                                ? Text(n.content, style: const TextStyle(color: Colors.white60), maxLines: 1, overflow: TextOverflow.ellipsis)
                                : null,
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
