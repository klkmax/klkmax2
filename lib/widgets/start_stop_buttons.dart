import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StartStopButtons extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final DateTime? currentStartTime;

  const StartStopButtons({
    super.key,
    required this.isRunning,
    required this.onStart,
    required this.onStop,
    this.currentStartTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isRunning
                ? AppTheme.neonCyan.withOpacity(0.15)
                : AppTheme.neonOrange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isRunning ? AppTheme.neonCyan : AppTheme.neonOrange,
              width: 1.5,
            ),
          ),
          child: Text(
            isRunning ? 'EN CURSO' : 'DETENIDO',
            style: TextStyle(
              color: isRunning ? AppTheme.neonCyan : AppTheme.neonOrange,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isRunning ? null : onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRunning ? Colors.grey.shade800 : AppTheme.neonCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: isRunning ? 0 : 10,
                  shadowColor: AppTheme.neonCyan.withOpacity(0.5),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 36),
                    SizedBox(height: 6),
                    Text('INICIO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isRunning ? onStop : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRunning ? AppTheme.neonOrange : Colors.grey.shade800,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: isRunning ? 10 : 0,
                  shadowColor: AppTheme.neonOrange.withOpacity(0.5),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.stop_rounded, size: 36),
                    SizedBox(height: 6),
                    Text('TERMINADO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
