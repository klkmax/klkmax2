import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/logo_km.dart';
import '../widgets/start_stop_buttons.dart';
import '../models/work_session.dart';
import '../services/overtime_calculator.dart';
import '../services/storage_service.dart';
import 'manual_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WorkSession? _currentSession;
  List<WorkSession> _todaySessions = [];
  Duration _todayNormal = Duration.zero;
  Duration _todayOvertime = Duration.zero;
  double _todayMoney = 0.0;

  Timer? _timer;
  DateTime _now = DateTime.now();
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadTodayData();
    _startClocks();
  }

  void _startClocks() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        if (_currentSession != null) {
          _elapsed = _now.difference(_currentSession!.start);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadTodayData() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final all = StorageService.getSessionsBetween(startOfDay, endOfDay);

    Duration normal = Duration.zero;
    Duration overtime = Duration.zero;
    double money = 0.0;
    WorkSession? running;

    for (final s in all) {
      if (s.end == null) {
        running = s;
        continue;
      }
      final result = OvertimeCalculator.calculate(
        start: s.start,
        end: s.end!,
        isHoliday: s.isHoliday,
      );
      normal += result.normalHours;
      overtime += result.overtimeHours;
      money += result.overtimeMoney;
    }

    setState(() {
      _todaySessions = all.where((s) => s.end != null).toList();
      _todayNormal = normal;
      _todayOvertime = overtime;
      _todayMoney = money;
      _currentSession = running;
      if (running != null) {
        _elapsed = DateTime.now().difference(running.start);
      }
    });
  }

  Future<void> _startSession() async {
    if (_currentSession != null) return;
    final session = WorkSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      start: DateTime.now(),
    );
    await StorageService.saveSession(session);
    setState(() {
      _currentSession = session;
      _elapsed = Duration.zero;
    });
  }

  Future<void> _stopSession() async {
    if (_currentSession == null) return;
    final ended = WorkSession(
      id: _currentSession!.id,
      start: _currentSession!.start,
      end: DateTime.now(),
      isManual: false,
      isHoliday: false,
    );
    await StorageService.saveSession(ended);
    final result = OvertimeCalculator.calculate(start: ended.start, end: ended.end!);
    setState(() {
      _currentSession = null;
      _elapsed = Duration.zero;
    });
    _loadTodayData();
    _showResultDialog(result);
  }

  void _showResultDialog(OvertimeResult result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Resumen de la jornada', style: TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Horas normales', OvertimeCalculator.formatDuration(result.normalHours)),
            _infoRow('Horas extra', OvertimeCalculator.formatDuration(result.overtimeHours)),
            _infoRow('Turno', result.shiftUsed),
            const SizedBox(height: 12),
            Text(
              'Monto extra: \$${result.overtimeMoney.toStringAsFixed(2)}',
              style: const TextStyle(color: AppTheme.neonOrange, fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar', style: TextStyle(color: AppTheme.neonCyan)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE d MMMM yyyy', 'es').format(_now);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.neonCyan.withOpacity(0.45)),
                ),
                child: Text(
                  '${OvertimeCalculator.formatTime12h(_now)}:${_now.second.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: AppTheme.neonCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              child: Column(
                children: [
                  const LogoKM(size: 72),
                  const SizedBox(height: 10),
                  const Text('KlkMax', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.neonCyan, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: AppTheme.premiumCard(borderColor: AppTheme.neonCyan),
                    child: Column(
                      children: [
                        const Text('RESUMEN DE HOY', style: TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13)),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _summaryItem('Normal', OvertimeCalculator.formatDuration(_todayNormal), AppTheme.neonCyan),
                            _summaryItem('Extra', OvertimeCalculator.formatDuration(_todayOvertime), AppTheme.neonOrange),
                            _summaryItem('\$ Extra', '\$${_todayMoney.toStringAsFixed(0)}', AppTheme.electricMagenta),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  StartStopButtons(
                    isRunning: _currentSession != null,
                    onStart: _startSession,
                    onStop: _stopSession,
                    currentStartTime: _currentSession?.start,
                  ),
                  if (_currentSession != null) ...[
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.neonCyan.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppTheme.neonCyan.withOpacity(0.5), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          const Text('TIEMPO TRANSCURRIDO', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                            _formatElapsed(_elapsed),
                            style: const TextStyle(color: AppTheme.neonCyan, fontSize: 42, fontWeight: FontWeight.w900, fontFeatures: [FontFeature.tabularFigures()], letterSpacing: 2),
                          ),
                          const SizedBox(height: 6),
                          Text('Desde ${OvertimeCalculator.formatTime12h(_currentSession!.start)}', style: const TextStyle(color: Colors.white60, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualEntryScreen()));
                        _loadTodayData();
                      },
                      icon: const Icon(Icons.edit_calendar_rounded, color: AppTheme.neonOrange),
                      label: const Text('Entrada manual de horas', style: TextStyle(color: AppTheme.neonOrange, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.neonOrange, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_todaySessions.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Registros de hoy', style: TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    const SizedBox(height: 12),
                    ..._todaySessions.map((s) {
                      final result = OvertimeCalculator.calculate(start: s.start, end: s.end!, isHoliday: s.isHoliday);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: AppTheme.premiumCard(borderColor: AppTheme.neonOrange.withOpacity(0.3)),
                        child: ListTile(
                          leading: const Icon(Icons.access_time_filled, color: AppTheme.neonOrange),
                          title: Text(
                            '${OvertimeCalculator.formatTime12h(s.start)} – ${OvertimeCalculator.formatTime12h(s.end!)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Extra: ${OvertimeCalculator.formatDuration(result.overtimeHours)}  •  \$${result.overtimeMoney.toStringAsFixed(2)}  •  ${s.shift}',
                            style: const TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
