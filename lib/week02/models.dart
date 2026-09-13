class Author {
  final String name;
  final String? country;

  const Author({required this.name, this.country});

  @override
  String toString() => '$name (${country ?? 'unknown'})';
}

enum Genre {
  craft('Craft'),
  theory('Theory'),
  unknown('Unknown');

  final String label;

  const Genre(this.label);

  static Genre fromString(String? raw) => switch (raw) {
    'craft' => Genre.craft,
    'theory' => Genre.theory,
    _ => Genre.unknown,
  };
}

abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({required this.title, required this.year});

  String describe();

  // The assignment leaves the age threshold open: older than 20 years is old.
  bool get isOld => DateTime.now().year - year > 20;
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrow: $title';
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // Keep untrusted input at this boundary; every local has a real type.
    final Object? title = json['title'];
    final Object? year = json['year'];
    final Object? pages = json['pages'];
    final Object? author = json['author'];
    final Object? country = json['country'];
    final Object? genre = json['genre'];
    final Object? description = json['description'];

    return Book(
      title: title is String ? title : 'Untitled',
      year: year is int ? year : 0,
      pages: pages is int ? pages : 0,
      author: Author(
        name: author is String ? author : 'Unknown',
        country: country is String ? country : null,
      ),
      genre: Genre.fromString(genre is String ? genre : null),
      description: description is String ? description : null,
    );
  }

  bool get isLong => pages > 400;

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
    bool clearDescription = false,
  }) => Book(
    title: title ?? this.title,
    year: year ?? this.year,
    pages: pages ?? this.pages,
    author: author ?? this.author,
    genre: genre ?? this.genre,
    description: clearDescription ? null : description ?? this.description,
  );

  @override
  String describe() =>
      '$title ($year), ${author.name}, $pages pages, ${genre.label}';

  @override
  String toString() => describe();
}

class Magazine extends LibraryItem {
  final int issue;

  const Magazine({
    required super.title,
    required super.year,
    required this.issue,
  });

  @override
  String describe() => '$title ($year), issue $issue';
}

class Ghost implements LibraryItem {
  @override
  final String title;

  @override
  final int year;

  const Ghost({required this.title, required this.year});

  @override
  bool get isOld => DateTime.now().year - year > 20;

  @override
  String describe() => '$title ($year), ghost catalogue entry';
}
