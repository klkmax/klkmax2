import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PinService {
  static const _pinKey = 'klkmax_pin_hash';
  static const _pinSetKey = 'klkmax_pin_set';

  static Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = _hash(pin);
    await prefs.setString(_pinKey, hash);
    await prefs.setBool(_pinSetKey, true);
  }

  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_pinKey);
    if (storedHash == null) return false;
    return storedHash == _hash(pin);
  }

  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinSetKey) ?? false;
  }

  static Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.remove(_pinSetKey);
  }

  static String _hash(String pin) {
    final bytes = utf8.encode(pin + 'KlkMaxSalt2026');
    return sha256.convert(bytes).toString();
  }
}
