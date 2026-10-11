import 'category.dart';

class Meeting {
  factory Meeting({
    required String id,
    required String title,
    required Category category,
    required DateTime when,
    required String place,
    required int limit,
    List<String> names = const [],
    bool online = false,
    String? description,
    bool favourite = false,
  }) => Meeting._(
    id: id,
    title: title,
    category: category,
    when: when,
    place: place,
    limit: limit,
    names: List.unmodifiable(names),
    online: online,
    description: description,
    favourite: favourite,
  );

  const Meeting._({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.place,
    required this.limit,
    required this.names,
    required this.online,
    required this.description,
    required this.favourite,
  });

  factory Meeting.empty() => Meeting(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    title: '',
    category: Category.coding,
    when: DateTime.now().add(const Duration(days: 1)),
    place: '',
    limit: 10,
  );

  final String id;
  final String title;
  final Category category;
  final DateTime when;
  final String place;
  final int limit;
  final List<String> names;
  final bool online;
  final String? description;
  final bool favourite;

  int get count => names.length;
  int get freePlaces => limit - count;
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  bool contains(String name) => names.any((person) => person == name);
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Meeting copyWith({
    String? title,
    Category? category,
    DateTime? when,
    String? place,
    int? limit,
    List<String>? names,
    bool? online,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) => Meeting(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    when: when ?? this.when,
    place: place ?? this.place,
    limit: limit ?? this.limit,
    names: names ?? this.names,
    online: online ?? this.online,
    description: clearDescription ? null : description ?? this.description,
    favourite: favourite ?? this.favourite,
  );
}
