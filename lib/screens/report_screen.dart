import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  Future<void> _generateReport(BuildContext context, {required bool firstHalf}) async {
    final now = DateTime.now();
    late DateTime start;
    late DateTime end;

    if (firstHalf) {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month, 15, 23, 59, 59);
    } else {
      start = DateTime(now.year, now.month, 16);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }

    final sessions = StorageService.getSessionsBetween(start, end);
    final settings = StorageService.getSettings();

    if (sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay registros en esta quincena'), backgroundColor: Colors.orange),
      );
      return;
    }

    await PdfService.generateBiweeklyReport(
      sessions: sessions,
      settings: settings,
      startDate: start,
      endDate: end,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Generar reporte quincenal', style: TextStyle(color: AppTheme.neonCyan, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('El PDF incluirá horas trabajadas, horas extra y el monto a pagar.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _generateReport(context, firstHalf: true),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Quincena 1 – 15'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonOrange,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _generateReport(context, firstHalf: false),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Quincena 16 – Fin de mes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neonCyan.withOpacity(0.3)),
              ),
              child: const Text(
                'Los reportes se generan 100% offline y se pueden compartir o guardar en tu dispositivo.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
