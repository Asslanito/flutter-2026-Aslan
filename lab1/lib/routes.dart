import 'package:flutter/material.dart';

import 'models/meeting.dart';
import 'models/profile.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/meeting';
  static const form = '/form';
}

class DetailArguments {
  const DetailArguments({
    required this.meeting,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onProfile,
  });

  final Meeting meeting;
  final Profile profile;
  final ValueChanged<Meeting> onChanged;
  final ValueChanged<Meeting> onDelete;
  final VoidCallback onProfile;
}

class FormArguments {
  const FormArguments({this.meeting});
  final Meeting? meeting;
}
