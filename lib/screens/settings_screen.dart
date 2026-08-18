import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../models/user_settings.dart';
import '../services/storage_service.dart';
import '../services/pin_service.dart';
import '../services/overtime_calculator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserSettings _settings;
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _holidayCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _settings = StorageService.getSettings();
    _nameCtrl.text = _settings.personName;
    _companyCtrl.text = _settings.companyName;
    _phoneCtrl.text = _settings.phone;
    _salaryCtrl.text = _settings.salary > 0 ? _settings.salary.toStringAsFixed(2) : '';
    _rateCtrl.text = _settings.overtimeRate.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _phoneCtrl.dispose();
    _salaryCtrl.dispose();
    _rateCtrl.dispose();
    _holidayCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    _settings.personName = _nameCtrl.text.trim();
    _settings.companyName = _companyCtrl.text.trim();
    _settings.phone = _phoneCtrl.text.trim();
    _settings.salary = double.tryParse(_salaryCtrl.text) ?? 0.0;
    _settings.overtimeRate = double.tryParse(_rateCtrl.text) ?? 210.49;
    await StorageService.saveSettings(_settings);
    OvertimeCalculator.overtimeRate = _settings.overtimeRate;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ajustes guardados'),
        backgroundColor: AppTheme.neonCyan,
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (file != null) {
      setState(() => _settings.profilePhotoPath = file.path);
      await _save();
    }
  }

  Future<void> _editShift(String label, String startKey, String endKey) async {
    String start = _settings.toMap()[startKey] as String;
    String end = _settings.toMap()[endKey] as String;

    final startParts = start.split(':');
    final endParts = end.split(':');
    TimeOfDay startTod = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
    TimeOfDay endTod = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));

    final newStart = await showTimePicker(
      context: context,
      initialTime: startTod,
      helpText: 'Inicio $label',
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.neonCyan, surface: AppTheme.cardBg),
        ),
        child: child!,
      ),
    );
    if (newStart == null) return;

    final newEnd = await showTimePicker(
      context: context,
      initialTime: endTod,
      helpText: 'Fin $label',
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.neonOrange, surface: AppTheme.cardBg),
        ),
        child: child!,
      ),
    );
    if (newEnd == null) return;

    final sStr = '${newStart.hour.toString().padLeft(2, '0')}:${newStart.minute.toString().padLeft(2, '0')}';
    final eStr = '${newEnd.hour.toString().padLeft(2, '0')}:${newEnd.minute.toString().padLeft(2, '0')}';

    setState(() {
      switch (label) {
        case 'Diurno':
          _settings.diurnoStart = sStr;
          _settings.diurnoEnd = eStr;
          break;
        case 'Vespertino':
          _settings.vespertinoStart = sStr;
          _settings.vespertinoEnd = eStr;
          break;
        case 'Nocturno':
          _settings.nocturnoStart = sStr;
          _settings.nocturnoEnd = eStr;
          break;
      }
    });
    await _save();
  }

  Future<void> _addHoliday() async {
    final text = _holidayCtrl.text.trim();
    if (text.isEmpty) return;
    // Expect dd/MM or dd/MM/yyyy
    setState(() {
      if (!_settings.holidays.contains(text)) {
        _settings.holidays = [..._settings.holidays, text];
      }
      _holidayCtrl.clear();
    });
    await _save();
  }

  Future<void> _changePin() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Nuevo PIN (4 dígitos)', style: TextStyle(color: AppTheme.neonCyan)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 6),
          decoration: const InputDecoration(counterText: ''),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (controller.text.length == 4) Navigator.pop(ctx, controller.text);
            },
            child: const Text('Guardar', style: TextStyle(color: AppTheme.neonOrange)),
          ),
        ],
      ),
    );
    if (result != null) {
      await PinService.setPin(result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN actualizado'), backgroundColor: AppTheme.neonCyan),
      );
    }
  }

  Future<void> _clearPin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Eliminar PIN', style: TextStyle(color: AppTheme.neonCyan)),
        content: const Text('¿Seguro que quieres quitar el PIN de acceso?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await PinService.clearPin();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN eliminado'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile photo
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.cardBg,
                  backgroundImage: _settings.profilePhotoPath != null
                      ? FileImage(File(_settings.profilePhotoPath!))
                      : null,
                  child: _settings.profilePhotoPath == null
                      ? const Icon(Icons.person, size: 48, color: AppTheme.neonCyan)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('Toca para cambiar foto', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
            const SizedBox(height: 24),

            _sectionTitle('Datos personales'),
            _field(_nameCtrl, 'Nombre completo', Icons.person_outline),
            _field(_companyCtrl, 'Empresa', Icons.business_outlined),
            _field(_phoneCtrl, 'Teléfono', Icons.phone_outlined, keyboard: TextInputType.phone),
            _field(_salaryCtrl, 'Salario base', Icons.attach_money, keyboard: TextInputType.number),

            const SizedBox(height: 20),
            _sectionTitle('Tarifa de hora extra'),
            _field(_rateCtrl, 'Monto por hora extra', Icons.payments_outlined, keyboard: TextInputType.number),

            const SizedBox(height: 20),
            _sectionTitle('Turnos (editables)'),
            _shiftTile('Diurno', _settings.diurnoStart, _settings.diurnoEnd),
            _shiftTile('Vespertino', _settings.vespertinoStart, _settings.vespertinoEnd),
            _shiftTile('Nocturno', _settings.nocturnoStart, _settings.nocturnoEnd),

            const SizedBox(height: 20),
            _sectionTitle('Días feriados'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _holidayCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'dd/MM o dd/MM/yyyy',
                      hintStyle: TextStyle(color: Colors.white30),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _addHoliday,
                  icon: const Icon(Icons.add_circle, color: AppTheme.neonOrange, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _settings.holidays.map((h) {
                return Chip(
                  label: Text(h, style: const TextStyle(color: Colors.black)),
                  backgroundColor: AppTheme.neonOrange,
                  deleteIcon: const Icon(Icons.close, size: 16, color: Colors.black),
                  onDeleted: () async {
                    setState(() {
                      _settings.holidays = _settings.holidays.where((e) => e != h).toList();
                    });
                    await _save();
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Seguridad'),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: AppTheme.neonCyan),
              title: const Text('Cambiar PIN', style: TextStyle(color: Colors.white)),
              onTap: _changePin,
            ),
            ListTile(
              leading: const Icon(Icons.lock_open, color: Colors.redAccent),
              title: const Text('Eliminar PIN', style: TextStyle(color: Colors.white70)),
              onTap: _clearPin,
            ),

            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('GUARDAR TODO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonOrange,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.8)),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.neonCyan),
        ),
      ),
    );
  }

  Widget _shiftTile(String label, String start, String end) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text('$start – $end', style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.edit, color: AppTheme.neonOrange, size: 20),
      onTap: () => _editShift(label, '${label.toLowerCase()}Start', '${label.toLowerCase()}End'),
    );
  }
}
