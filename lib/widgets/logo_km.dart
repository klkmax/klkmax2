import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LogoKM extends StatelessWidget {
  final double size;
  const LogoKM({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.neonOrange, AppTheme.neonCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonCyan.withOpacity(0.45),
            blurRadius: 22,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppTheme.neonOrange.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'KM',
          style: TextStyle(
            fontSize: size * 0.44,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0D0D1A),
            letterSpacing: -3.5,
            height: 1,
          ),
        ),
      ),
    );
  }
}
