import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/pin_service.dart';
import '../theme/app_theme.dart';
import '../widgets/logo_km.dart';
import 'main_navigation.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final List<String> _pin = [];
  bool _isWrong = false;
  bool _isLoading = true;
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  Future<void> _checkPin() async {
    final exists = await PinService.hasPin();
    setState(() {
      _hasPin = exists;
      _isLoading = false;
    });
  }

  void _onNumberPressed(String number) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin.add(number);
      _isWrong = false;
    });
    if (_pin.length == 4) _verify();
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin.removeLast();
      _isWrong = false;
    });
  }

  Future<void> _verify() async {
    final pinStr = _pin.join();
    final correct = await PinService.verifyPin(pinStr);
    if (correct) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      setState(() {
        _isWrong = true;
        _pin.clear();
      });
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _createFirstPin() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Crear PIN de acceso', style: TextStyle(color: AppTheme.neonCyan)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
          decoration: const InputDecoration(hintText: '••••', counterText: ''),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.length == 4) Navigator.pop(ctx, controller.text);
            },
            child: const Text('Guardar', style: TextStyle(color: AppTheme.neonOrange)),
          ),
        ],
      ),
    );
    if (result != null && result.length == 4) {
      await PinService.setPin(result);
      setState(() => _hasPin = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(child: CircularProgressIndicator(color: AppTheme.neonCyan)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const LogoKM(size: 90),
            const SizedBox(height: 16),
            const Text('KlkMax', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.neonCyan, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(
              _hasPin ? 'Ingresa tu PIN' : 'Crea tu PIN de 4 dígitos',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? (_isWrong ? Colors.redAccent : AppTheme.neonOrange) : Colors.transparent,
                    border: Border.all(color: _isWrong ? Colors.redAccent : AppTheme.neonCyan, width: 2),
                  ),
                );
              }),
            ),
            if (_isWrong)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('PIN incorrecto', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            const Spacer(),
            _buildKeypad(),
            const SizedBox(height: 20),
            if (!_hasPin)
              TextButton(
                onPressed: _createFirstPin,
                child: const Text('Crear PIN ahora', style: TextStyle(color: AppTheme.neonOrange, fontSize: 16)),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9'], ['', '0', 'del']];
    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 72);
              return InkWell(
                onTap: () {
                  if (key == 'del') _onDelete();
                  else _onNumberPressed(key);
                },
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cardBg,
                    border: Border.all(color: AppTheme.neonCyan.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      key == 'del' ? '⌫' : key,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
