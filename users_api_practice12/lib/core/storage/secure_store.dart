import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keychain (iOS) / Keystore-backed storage (Android). Tokens live only here.
class SecureStore {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'token';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } on PlatformException catch (e) {
      // e.g. Android keys invalidated after the lock screen was removed
      log('secure read failed: ${e.code}', name: 'secure');
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
