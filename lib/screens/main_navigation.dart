import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/logo_km.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'notes_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';
import 'calculator_screen.dart';
import 'manual_entry_screen.dart';
import 'history_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
    NotesScreen(),
    ReportScreen(),
    CalculatorScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = [
    'Inicio',
    'Calendario',
    'Notas',
    'Reportes',
    'Calculadora',
    'Ajustes',
  ];

  void _onSelect(int index) {
    setState(() => _currentIndex = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = StorageService.getSettings();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
        backgroundColor: AppTheme.deepPurple,
        foregroundColor: AppTheme.neonCyan,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.cardBg,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.deepPurple, Color(0xFF2A004D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LogoKM(size: 64),
                    const SizedBox(height: 14),
                    const Text(
                      'KlkMax',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.neonCyan,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settings.personName.isEmpty ? 'Usuario' : settings.personName,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    if (settings.companyName.isNotEmpty)
                      Text(
                        settings.companyName,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    _drawerItem(icon: Icons.home_rounded, title: 'Inicio', index: 0),
                    _drawerItem(icon: Icons.calendar_month_rounded, title: 'Calendario', index: 1),
                    _drawerItem(icon: Icons.notes_rounded, title: 'Notas', index: 2),
                    _drawerItem(icon: Icons.picture_as_pdf_rounded, title: 'Reportes PDF', index: 3),
                    _drawerItem(icon: Icons.calculate_rounded, title: 'Calculadora', index: 4),
                    const Divider(color: Colors.white12, height: 32),
                    _drawerItem(
                      icon: Icons.edit_calendar_rounded,
                      title: 'Entrada Manual',
                      index: -1,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualEntryScreen()));
                      },
                    ),
                    _drawerItem(
                      icon: Icons.history_rounded,
                      title: 'Historial completo',
                      index: -1,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                      },
                    ),
                    _drawerItem(icon: Icons.settings_rounded, title: 'Ajustes', index: 5),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'KlkMax • Offline',
                  style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required int index,
    VoidCallback? onTap,
  }) {
    final isSelected = index == _currentIndex && index >= 0;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.neonOrange : AppTheme.neonCyan),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.neonOrange : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.neonOrange.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap ?? () => _onSelect(index),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
