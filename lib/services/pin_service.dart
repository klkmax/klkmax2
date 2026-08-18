import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PinService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _pinKey = 'klkmax_pin_hash';
  static const _pinSetKey = 'klkmax_pin_set';

  static Future<void> setPin(String pin) async {
    final hash = _hash(pin);
    await _storage.write(key: _pinKey, value: hash);
    await _storage.write(key: _pinSetKey, value: 'true');
  }

  static Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _pinKey);
    if (storedHash == null) return false;
    return storedHash == _hash(pin);
  }

  static Future<bool> hasPin() async {
    final value = await _storage.read(key: _pinSetKey);
    return value == 'true';
  }

  static Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _pinSetKey);
  }

  static String _hash(String pin) {
    final bytes = utf8.encode(pin + 'KlkMaxSalt2026');
    return sha256.convert(bytes).toString();
  }
}
