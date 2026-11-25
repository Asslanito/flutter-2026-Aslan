import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
}

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {String? token}) : _token = token;

  final SecureStore _store;
  String? _token;

  bool get signedIn => _token != null;

  /// Fake login: any password of 8+ characters works, after one second.
  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (password.length < 8) throw const InvalidCredentialsException();
    final token = 'tok_${email.hashCode}';
    await _store.saveToken(token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    _token = null;
    notifyListeners();
  }

  /// Debug-only helper for "Copy token" — never printed.
  Future<String?> debugToken() => _store.readToken();
}
