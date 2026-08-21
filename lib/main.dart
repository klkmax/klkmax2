import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/overtime_calculator.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es', null);
  await StorageService.init();

  final settings = StorageService.getSettings();
  OvertimeCalculator.overtimeRate = settings.overtimeRate;

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0D0D1A),
      ),
    );
  }

  runApp(const KlkMaxApp());
}

class KlkMaxApp extends StatelessWidget {
  const KlkMaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KlkMax',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
