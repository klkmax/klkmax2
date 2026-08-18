import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/work_session.dart';
import '../services/overtime_calculator.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<WorkSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _sessions = StorageService.getAllSessions().where((s) => s.end != null).toList();
    });
  }

  Future<void> _deleteSession(WorkSession session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Eliminar registro', style: TextStyle(color: AppTheme.neonCyan)),
        content: const Text('¿Estás seguro de eliminar este registro?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.deleteSession(session.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('Historial de Sesiones')),
      body: _sessions.isEmpty
          ? const Center(child: Text('No hay registros todavía', style: TextStyle(color: Colors.white38, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final s = _sessions[index];
                final result = OvertimeCalculator.calculate(start: s.start, end: s.end!, isHoliday: s.isHoliday);
                final dayName = DateFormat('EEEE', 'es').format(s.start);
                final dateStr = DateFormat('dd/MM/yyyy').format(s.start);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: AppTheme.premiumCard(borderColor: AppTheme.neonOrange.withOpacity(0.3)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    title: Text('$dayName • $dateStr', style: const TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${OvertimeCalculator.formatTime12h(s.start)} – ${OvertimeCalculator.formatTime12h(s.end!)}',
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Normal: ${OvertimeCalculator.formatDuration(result.normalHours)}  |  Extra: ${OvertimeCalculator.formatDuration(result.overtimeHours)}',
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                        Text(
                          'Monto extra: \$${result.overtimeMoney.toStringAsFixed(2)}  •  Turno: ${s.shift}',
                          style: const TextStyle(color: AppTheme.neonOrange, fontWeight: FontWeight.bold),
                        ),
                        if (s.isManual) const Text('Entrada manual', style: TextStyle(color: Colors.white38, fontSize: 11)),
                        if (s.isHoliday) const Text('Día feriado', style: TextStyle(color: AppTheme.electricMagenta, fontSize: 11)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _deleteSession(s),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
