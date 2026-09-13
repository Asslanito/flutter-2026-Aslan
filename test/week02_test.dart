import 'package:flutter_2026_aslan/week02/catalogue.dart';
import 'package:flutter_2026_aslan/week02/data.dart';
import 'package:flutter_2026_aslan/week02/models.dart';
import 'package:flutter_2026_aslan/week02/shelf_state.dart' as shelf;
import 'package:test/test.dart';

void main() {
  final books = rawBooks.map(Book.fromJson).toList();

  group('Input and models', () {
    test('both incomplete starter entries retain useful data', () {
      final patterns = books[3];
      expect(patterns.title, 'Design Patterns');
      expect(patterns.author.country, isNull);
      expect(patterns.pages, 395);
      expect(patterns.genre, Genre.theory);

      final broken = books[5];
      expect(broken.title, 'Broken Record');
      expect(broken.year, 2021);
      expect(broken.author.name, 'Unknown');
      expect(broken.pages, 0);
      expect(broken.author.country, isNull);
      expect(broken.description, isNull);
      expect(broken.genre, Genre.unknown);
    });

    test('missing or wrongly typed JSON values use safe defaults', () {
      final book = Book.fromJson(<String, Object?>{
        'title': 10,
        'year': '2026',
        'pages': null,
        'author': false,
        'country': 42,
        'genre': 123,
        'description': <String>[],
      });
      expect(book.title, 'Untitled');
      expect(book.year, 0);
      expect(book.pages, 0);
      expect(book.author.name, 'Unknown');
      expect(book.author.country, isNull);
      expect(book.genre, Genre.unknown);
      expect(book.description, isNull);
      expect(Book.fromJson(<String, Object?>{}).pages, 0);
    });

    test('genre handles null and unexpected strings', () {
      expect(Genre.fromString(null), Genre.unknown);
      expect(Genre.fromString('fiction'), Genre.unknown);
      expect(Genre.fromString('craft'), Genre.craft);
      expect(Genre.fromString('theory'), Genre.theory);
      expect(Genre.unknown.label, 'Unknown');
    });

    test('copyWith preserves the original and can clear a description', () {
      final original = books[2];
      final copy = original.copyWith(title: 'Refactoring revised', pages: 401);
      expect(original.title, 'Refactoring');
      expect(original.pages, 448);
      expect(copy.title, 'Refactoring revised');
      expect(copy.pages, 401);
      expect(copy.author, same(original.author));
      expect(copy.description, original.description);
      expect(original.copyWith(clearDescription: true).description, isNull);
      expect(
        original.copyWith(description: 'New description').description,
        'New description',
      );
      expect(original.copyWith(pages: 400).isLong, isFalse);
      expect(copy.isLong, isTrue);
    });
  });

  group('Library behaviour', () {
    test('empty and non-book catalogues are safe', () {
      final library = Library();
      expect(library.findByTitle('Absent'), isNull);
      expect(library.countryOf('Absent'), 'unknown');
      expect(library.averagePages, 0.0);
      expect(library.bookCountByAuthor, isEmpty);
      expect(library.authorNames, isEmpty);
      expect(library.genres, isEmpty);
      expect(library.displayLines, ['CATALOGUE']);
      library.add(const Magazine(title: 'Magazine', year: 2026, issue: 2));
      library.add(const Ghost(title: 'Ghost', year: 1900));
      expect(library.titles, ['Magazine', 'Ghost']);
      expect(library.findByTitle('Magazine'), isNull);
      expect(library.averagePages, 0.0);
    });

    test('queries return the expected catalogue values', () {
      final library = Library(books);
      expect(library.titles, [
        'Clean Code',
        'The Pragmatic Programmer',
        'Refactoring',
        'Design Patterns',
        'Domain-Driven Design',
        'Broken Record',
      ]);
      expect(library.booksAfter2010.map((book) => book.title), [
        'The Pragmatic Programmer',
        'Refactoring',
        'Broken Record',
      ]);
      expect(library.averagePages, closeTo(2219 / 6, 0.000001));
      expect(library.countryOf('Clean Code'), 'USA');
      expect(library.countryOf('Design Patterns'), 'unknown');
      expect(library.countryOf('Broken Record'), 'unknown');
      expect(library.genres, {Genre.craft, Genre.theory, Genre.unknown});
      expect(library.displayLines.last, '(incomplete data)');
      expect(library.displayLines[1], 'Clean Code (2008)');
      expect(library.displayLines.skip(7).take(6), library.authorNames);
    });

    test('authors are counted and deduplicated across multiple books', () {
      final library = Library([
        books.first,
        books.first.copyWith(title: 'Another Martin book', year: 2010),
        books[1],
        const Magazine(title: 'Monthly', year: 2026, issue: 1),
      ]);
      expect(library.bookCountByAuthor, {'Martin': 2, 'Hunt': 1});
      expect(library.authorNames, {'Martin', 'Hunt'});
      expect(library.booksAfter2010.map((book) => book.title), [
        'The Pragmatic Programmer',
      ]);
      expect(library.averagePages, closeTo(1280 / 3, 0.000001));
      expect(library.displayLines, isNot(contains('(incomplete data)')));
    });

    test('report is reused and refreshed after add', () {
      final library = Library([books.first]);
      final report = library.report;
      expect(library.report, same(report));
      library.add(books.last);
      expect(library.report, contains('Broken Record (2021)'));
      expect(library.report, contains('(incomplete data)'));
    });

    test('open initializes the late timestamp once', () {
      final library = Library();
      final before = DateTime.now();
      library.open();
      final openedAt = library.openedAt;
      expect(openedAt.isBefore(before), isFalse);
      library.open();
      expect(library.openedAt, same(openedAt));
    });

    test('hierarchy and borrowable behaviour are available', () {
      final year = DateTime.now().year;
      expect(books.first.borrowLabel(), 'Borrow: Clean Code');
      expect(books.first, isA<Borrowable>());
      final magazine = Magazine(title: 'Monthly', year: year, issue: 2);
      final ghost = Ghost(title: 'Missing', year: year - 21);
      expect(magazine, isA<LibraryItem>());
      expect(magazine, isNot(isA<Borrowable>()));
      expect(magazine.isOld, isFalse);
      expect(magazine.describe(), contains('issue 2'));
      expect(ghost, isA<LibraryItem>());
      expect(ghost.isOld, isTrue);
      expect(ghost.describe(), contains('Missing'));
      expect(books.first.copyWith(year: year - 20).isOld, isFalse);
    });
  });

  group('Dart 3', () {
    test('record statistics handle both full and empty lists', () {
      final ({int count, double avgPages}) stats = shelf.statsOf(books);
      expect(stats.count, 6);
      expect(stats.avgPages, closeTo(2219 / 6, 0.000001));
      expect(shelf.statsOf([]), (count: 0, avgPages: 0.0));
    });

    test('all three shelf states expose their payloads', () {
      expect(shelf.describe(const shelf.Empty()), 'The shelf is empty.');
      expect(shelf.describe(shelf.Ready(books)), contains('6 books'));
      expect(
        shelf.describe(const shelf.Broken('Read failed')),
        'The shelf is broken: Read failed',
      );
    });
  });
}
