import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user_settings.dart';
import '../models/work_session.dart';
import 'overtime_calculator.dart';

class PdfService {
  static Future<void> generateBiweeklyReport({
    required List<WorkSession> sessions,
    required UserSettings settings,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    Duration totalNormal = Duration.zero;
    Duration totalOvertime = Duration.zero;
    double totalMoney = 0.0;

    final rows = <List<String>>[];

    for (final s in sessions) {
      if (s.end == null) continue;
      final result = OvertimeCalculator.calculate(
        start: s.start,
        end: s.end!,
        isHoliday: s.isHoliday,
      );
      totalNormal += result.normalHours;
      totalOvertime += result.overtimeHours;
      totalMoney += result.overtimeMoney;

      rows.add([
        DateFormat('dd/MM/yyyy').format(s.start),
        OvertimeCalculator.formatTime12h(s.start),
        OvertimeCalculator.formatTime12h(s.end!),
        OvertimeCalculator.formatDuration(result.normalHours),
        OvertimeCalculator.formatDuration(result.overtimeHours),
        '\$${result.overtimeMoney.toStringAsFixed(2)}',
        s.isHoliday ? 'Feriado' : result.shiftUsed,
      ]);
    }

    final dateRange =
        '${DateFormat('dd/MM/yyyy').format(startDate)} – ${DateFormat('dd/MM/yyyy').format(endDate)}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'KlkMax – Reporte Quincenal',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Período: $dateRange',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 8),
                if (settings.personName.isNotEmpty)
                  pw.Text('Empleado: ${settings.personName}',
                      style: const pw.TextStyle(fontSize: 11)),
                if (settings.companyName.isNotEmpty)
                  pw.Text('Empresa: ${settings.companyName}',
                      style: const pw.TextStyle(fontSize: 11)),
                if (settings.phone.isNotEmpty)
                  pw.Text('Tel: ${settings.phone}',
                      style: const pw.TextStyle(fontSize: 11)),
                pw.Divider(thickness: 1.5),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: [
              'Fecha',
              'Entrada',
              'Salida',
              'Normal',
              'Extra',
              'Monto',
              'Turno',
            ],
            data: rows,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 9,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.center,
            cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 3),
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          ),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.teal200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('RESUMEN',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 13)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                        'Horas normales: ${OvertimeCalculator.formatDuration(totalNormal)}'),
                    pw.Text(
                        'Horas extra: ${OvertimeCalculator.formatDuration(totalOvertime)}'),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Total a pagar por horas extra: \$${totalMoney.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                    color: PdfColors.orange800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Tarifa hora extra: \$${settings.overtimeRate.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'Generado con KlkMax • 100% offline • ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'KlkMax_Reporte_${DateFormat('yyyyMMdd').format(startDate)}.pdf',
    );
  }
}
