import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  void _onNumberPressed(String number) {
    setState(() {
      if (_shouldResetDisplay || _display == '0') {
        _display = number;
        _shouldResetDisplay = false;
      } else if (_display.length < 12) {
        _display += number;
      }
    });
  }

  void _onOperatorPressed(String op) {
    setState(() {
      _firstOperand = double.tryParse(_display) ?? 0;
      _operator = op;
      _expression = '$_display $op';
      _shouldResetDisplay = true;
    });
  }

  void _onEqualsPressed() {
    if (_operator == null || _firstOperand == null) return;
    final secondOperand = double.tryParse(_display) ?? 0;
    double result = 0;
    switch (_operator) {
      case '+': result = _firstOperand! + secondOperand; break;
      case '-': result = _firstOperand! - secondOperand; break;
      case '×': result = _firstOperand! * secondOperand; break;
      case '÷':
        if (secondOperand == 0) {
          setState(() {
            _display = 'Error';
            _expression = '';
            _firstOperand = null;
            _operator = null;
            _shouldResetDisplay = true;
          });
          return;
        }
        result = _firstOperand! / secondOperand;
        break;
    }
    setState(() {
      _expression = '$_expression $_display =';
      if (result == result.toInt()) {
        _display = result.toInt().toString();
      } else {
        _display = result.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      }
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = true;
    });
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_display.length > 1) _display = _display.substring(0, _display.length - 1);
      else _display = '0';
    });
  }

  void _onDecimal() {
    if (_shouldResetDisplay) {
      setState(() { _display = '0.'; _shouldResetDisplay = false; });
      return;
    }
    if (!_display.contains('.')) setState(() => _display += '.');
  }

  Widget _buildButton(String text, {Color? bgColor, Color? textColor, int flex = 1, VoidCallback? onPressed}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor ?? AppTheme.cardBg,
            foregroundColor: textColor ?? Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
          child: Text(text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor ?? Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_expression, style: const TextStyle(color: Colors.white54, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(_display, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: Column(
                children: [
                  Expanded(child: Row(children: [
                    _buildButton('C', bgColor: AppTheme.neonOrange, textColor: Colors.black, onPressed: _onClear),
                    _buildButton('⌫', bgColor: Colors.white12, onPressed: _onBackspace),
                    _buildButton('%', bgColor: Colors.white12, onPressed: () {
                      final value = double.tryParse(_display) ?? 0;
                      setState(() { _display = (value / 100).toString(); _shouldResetDisplay = true; });
                    }),
                    _buildButton('÷', bgColor: AppTheme.neonCyan, textColor: Colors.black, onPressed: () => _onOperatorPressed('÷')),
                  ])),
                  Expanded(child: Row(children: [
                    _buildButton('7', onPressed: () => _onNumberPressed('7')),
                    _buildButton('8', onPressed: () => _onNumberPressed('8')),
                    _buildButton('9', onPressed: () => _onNumberPressed('9')),
                    _buildButton('×', bgColor: AppTheme.neonCyan, textColor: Colors.black, onPressed: () => _onOperatorPressed('×')),
                  ])),
                  Expanded(child: Row(children: [
                    _buildButton('4', onPressed: () => _onNumberPressed('4')),
                    _buildButton('5', onPressed: () => _onNumberPressed('5')),
                    _buildButton('6', onPressed: () => _onNumberPressed('6')),
                    _buildButton('-', bgColor: AppTheme.neonCyan, textColor: Colors.black, onPressed: () => _onOperatorPressed('-')),
                  ])),
                  Expanded(child: Row(children: [
                    _buildButton('1', onPressed: () => _onNumberPressed('1')),
                    _buildButton('2', onPressed: () => _onNumberPressed('2')),
                    _buildButton('3', onPressed: () => _onNumberPressed('3')),
                    _buildButton('+', bgColor: AppTheme.neonCyan, textColor: Colors.black, onPressed: () => _onOperatorPressed('+')),
                  ])),
                  Expanded(child: Row(children: [
                    _buildButton('0', flex: 2, onPressed: () => _onNumberPressed('0')),
                    _buildButton('.', onPressed: _onDecimal),
                    _buildButton('=', bgColor: AppTheme.neonOrange, textColor: Colors.black, onPressed: _onEqualsPressed),
                  ])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
