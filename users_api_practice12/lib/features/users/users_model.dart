import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool saving = false;
  bool fromCache = false;

  List<String> get cities => ({
        for (final u in items)
          if (u.address.city.isNotEmpty) u.address.city,
      }.toList()
        ..sort());

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final r = await _repo.getAll();
      items = r.items;
      fromCache = r.fromCache;
    } on ApiException catch (e) {
      error = e;
      fromCache = false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Throws [ApiException] to the caller (the form shows a SnackBar).
  Future<void> create(User draft) async {
    if (saving) return; // a double tap sends one request
    saving = true;
    notifyListeners();
    try {
      final created = await _repo.create(draft);
      items = [created, ...items];
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
