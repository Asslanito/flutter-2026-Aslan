import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart' as shelf;

void main() {
  final library = Library(rawBooks.map(Book.fromJson));
  library.open();
  library.add(const Magazine(title: 'Dart Monthly', year: 2026, issue: 2));
  library.add(const Ghost(title: 'Lost Manuscript', year: 1900));

  print(library.report);
  print('\nCOLLECTION QUERIES');
  print('Every title: ${library.titles.join(', ')}');
  print(
    'Books after 2010: ${library.booksAfter2010.map((b) => b.title).join(', ')}',
  );
  print('Average pages: ${library.averagePages.toStringAsFixed(2)}');
  print('Books by author: ${library.bookCountByAuthor}');
  print('Distinct authors: ${library.authorNames.join(', ')}');
  print('Genres: ${library.genres.map((genre) => genre.label).join(', ')}');

  print('\nNULL SAFETY');
  print('Library opened: ${library.openedAt.toIso8601String()}');
  print('Clean Code country: ${library.countryOf('Clean Code')}');
  print('Design Patterns country: ${library.countryOf('Design Patterns')}');
  print('Missing title country: ${library.countryOf('Missing title')}');
  print('Missing title: ${library.findByTitle('Missing title')}');
  final brokenRecord = library.findByTitle('Broken Record');
  print('Incomplete entry: $brokenRecord');

  final refactoring = library.findByTitle('Refactoring');
  if (refactoring case final Book book) {
    final description = book.description;
    if (description is String) {
      print('Description: ${description.toUpperCase()}');
    }
    final revised = book.copyWith(pages: 450);
    print('Copy: ${revised.pages} pages; original: ${book.pages} pages');
    print('Long book: ${book.isLong}; ${book.borrowLabel()}');
  }

  print('\nHIERARCHY');
  for (final item in library.items) {
    print('${item.describe()} | old: ${item.isOld}');
  }

  final books = library.books.toList();
  print('\nDART 3');
  final stats = shelf.statsOf(books);
  print('Record: $stats');
  final (:count, :avgPages) = stats;
  print('Count: $count; average: ${avgPages.toStringAsFixed(2)}');
  print(shelf.describe(const shelf.Empty()));
  print(shelf.describe(shelf.Ready(books)));
  print(shelf.describe(const shelf.Broken('Catalogue unavailable')));
}
