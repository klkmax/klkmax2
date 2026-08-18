import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/work_session.dart';
import '../services/overtime_calculator.dart';
import '../services/storage_service.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 15, minute: 0);
  bool _isHoliday = false;
  String _selectedShift = 'Auto';
  final _noteController = TextEditingController();

  final List<String> _weekDays = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonOrange,
              onPrimary: Colors.black,
              surface: AppTheme.cardBg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonCyan,
              onPrimary: Colors.black,
              surface: AppTheme.cardBg,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  Future<void> _saveManualEntry() async {
    final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _startTime.hour, _startTime.minute);
    var end = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _endTime.hour, _endTime.minute);
    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      end = end.add(const Duration(days: 1));
    }

    final ShiftType shiftType = switch (_selectedShift) {
      'Diurno' => ShiftType.diurno,
      'Vespertino' => ShiftType.vespertino,
      'Nocturno' => ShiftType.nocturno,
      _ => ShiftType.auto,
    };

    final session = WorkSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      start: start,
      end: end,
      isManual: true,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      isHoliday: _isHoliday,
      shift: _selectedShift,
    );

    await StorageService.saveSession(session);

    final result = OvertimeCalculator.calculate(
      start: start,
      end: end,
      isHoliday: _isHoliday,
      shift: shiftType,
    );

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Registro guardado', style: TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Día: ${_weekDays[start.weekday - 1]}'),
            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(start)}'),
            Text('Entrada: ${OvertimeCalculator.formatTime12h(start)}'),
            Text('Salida: ${OvertimeCalculator.formatTime12h(end)}'),
            Text('Turno: ${result.shiftUsed}'),
            const SizedBox(height: 12),
            Text('Horas normales: ${OvertimeCalculator.formatDuration(result.normalHours)}'),
            Text('Horas extra: ${OvertimeCalculator.formatDuration(result.overtimeHours)}'),
            Text(
              'Monto: \$${result.overtimeMoney.toStringAsFixed(2)}',
              style: const TextStyle(color: AppTheme.neonOrange, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppTheme.neonCyan)),
          ),
        ],
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dayName = _weekDays[_selectedDate.weekday - 1];

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('Entrada Manual')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.premiumCard(borderColor: AppTheme.neonCyan),
              child: Column(
                children: [
                  Text(dayName, style: const TextStyle(color: AppTheme.neonCyan, fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month, size: 20),
                    label: const Text('Elegir otro día'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.neonOrange,
                      side: const BorderSide(color: AppTheme.neonOrange, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _timeCard(label: 'Hora de entrada', time: _startTime, onTap: () => _pickTime(isStart: true), icon: Icons.login_rounded),
            const SizedBox(height: 14),
            _timeCard(label: 'Hora de salida', time: _endTime, onTap: () => _pickTime(isStart: false), icon: Icons.logout_rounded),
            const SizedBox(height: 24),
            const Text('Turno', style: TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _shiftChip('Auto'),
                _shiftChip('Diurno'),
                _shiftChip('Vespertino'),
                _shiftChip('Nocturno'),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Día feriado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: const Text('Todo el tiempo se calculará como hora extra', style: TextStyle(color: Colors.white54, fontSize: 13)),
              value: _isHoliday,
              activeColor: AppTheme.neonOrange,
              onChanged: (v) => setState(() => _isHoliday = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Nota (opcional)',
                prefixIcon: Icon(Icons.note_alt_outlined, color: AppTheme.neonCyan),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _saveManualEntry,
              icon: const Icon(Icons.save_rounded, size: 24),
              label: const Text('GUARDAR REGISTRO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonOrange,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shiftChip(String label) {
    final isSelected = _selectedShift == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.neonOrange,
      backgroundColor: AppTheme.cardBg,
      labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontWeight: FontWeight.bold),
      side: BorderSide(color: isSelected ? AppTheme.neonOrange : AppTheme.neonCyan.withOpacity(0.4)),
      onSelected: (_) => setState(() => _selectedShift = label),
    );
  }

  Widget _timeCard({required String label, required TimeOfDay time, required VoidCallback onTap, required IconData icon}) {
    final formatted = OvertimeCalculator.formatTime12h(DateTime(2024, 1, 1, time.hour, time.minute));
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: AppTheme.premiumCard(),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.neonCyan, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(formatted, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const Icon(Icons.edit, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
