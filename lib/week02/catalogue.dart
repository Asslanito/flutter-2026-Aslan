import 'models.dart';

class Library {
  final List<LibraryItem> items;
  late final DateTime openedAt;
  bool _opened = false;
  String? _cachedReport;

  Library([Iterable<LibraryItem> initialItems = const []])
    : items = List<LibraryItem>.of(initialItems);

  void add(LibraryItem item) {
    items.add(item);
    _cachedReport = null;
  }

  void open() {
    if (_opened) return;
    openedAt = DateTime.now();
    _opened = true;
  }

  Book? findByTitle(String title) =>
      books.where((book) => book.title == title).firstOrNull;

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  Iterable<Book> get books => items.whereType<Book>();

  List<String> get titles => items.map((item) => item.title).toList();

  List<Book> get booksAfter2010 =>
      books.where((book) => book.year > 2010).toList();

  // fold works on an empty list; reduce throws.
  double get averagePages => books.isEmpty
      ? 0.0
      : books.fold<int>(0, (total, book) => total + book.pages) / books.length;

  Map<String, int> get bookCountByAuthor => books.fold<Map<String, int>>(
    <String, int>{},
    (counts, book) => {
      ...counts,
      book.author.name: (counts[book.author.name] ?? 0) + 1,
    },
  );

  Set<String> get authorNames => books.map((book) => book.author.name).toSet();

  Set<Genre> get genres => books.map((book) => book.genre).toSet();

  List<String> get displayLines => [
    'CATALOGUE',
    for (final book in books) '${book.title} (${book.year})',
    ...authorNames,
    if (books.any((book) => book.pages == 0)) '(incomplete data)',
  ];

  String get report => _cachedReport ??= displayLines.join('\n');
}
