String? validateTitle(String? value) {
  final length = (value ?? '').trim().length;
  return length < 3 || length > 60 ? 'Use 3 to 60 characters' : null;
}

String? validatePlace(String? value, bool online) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return online ? 'Enter a meeting link' : 'Enter a place';
  if (online && !text.contains('://')) return 'Include :// in the link';
  return null;
}

String? validateLimit(String? value, int count) {
  final limit = int.tryParse((value ?? '').trim());
  if (limit == null || limit < 1 || limit > 500) return 'Enter a whole number from 1 to 500';
  if (limit < count) return 'At least $count places are needed';
  return null;
}

String? validateWhen(DateTime? when, bool isNew) {
  if (when == null) return 'Choose date and time';
  if (isNew && !when.isAfter(DateTime.now())) return 'Choose a future date and time';
  return null;
}

String? validateDescription(String? value) =>
    (value ?? '').length > 500 ? 'Use up to 500 characters' : null;
