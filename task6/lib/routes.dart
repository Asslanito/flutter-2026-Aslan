import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'edit_screen.dart';
import 'students.dart';

abstract final class Routes {
  static const students = '/';
  static const student = '/student';
  static const edit = '/edit';

  static Route<dynamic>? generate(RouteSettings settings) {
    final argument = settings.arguments;
    if (argument is! Student) return null;
    return switch (settings.name) {
      student => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(student: argument),
      ),
      edit => MaterialPageRoute<String>(
        settings: settings,
        builder: (_) => EditScreen(student: argument),
      ),
      _ => null,
    };
  }
}
