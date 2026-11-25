import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'user.dart';

/// The last good list, in the Documents directory (never Temporary).
class UsersCache {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/users.json');
  }

  Future<void> save(List<User> list) async {
    if (kIsWeb) return; // no file system in the browser
    try {
      final f = await _file();
      await f.writeAsString(jsonEncode([for (final u in list) u.toJson()]));
    } on FileSystemException catch (e) {
      log('cache write failed: ${e.message}', name: 'cache');
    }
  }

  Future<List<User>?> load() async {
    if (kIsWeb) return null;
    try {
      final f = await _file();
      if (!await f.exists()) return null;
      final raw = jsonDecode(await f.readAsString()) as List<dynamic>;
      return [for (final e in raw) User.fromJson(e as Map<String, dynamic>)];
    } on FileSystemException catch (e) {
      log('cache read failed: ${e.message}', name: 'cache');
      return null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
