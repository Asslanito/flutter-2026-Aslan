import 'models.dart';

sealed class ShelfState {
  const ShelfState();
}

final class Empty extends ShelfState {
  const Empty();
}

final class Ready extends ShelfState {
  final List<Book> books;

  const Ready(this.books);
}

final class Broken extends ShelfState {
  final String message;

  const Broken(this.message);
}

String describe(ShelfState state) => switch (state) {
  Empty() => 'The shelf is empty.',
  Ready(:final books) => 'The shelf is ready with ${books.length} books.',
  Broken(:final message) => 'The shelf is broken: $message',
};

({int count, double avgPages}) statsOf(List<Book> books) => (
  count: books.length,
  // fold, unlike reduce, can start at zero even when there are no books.
  avgPages: books.isEmpty
      ? 0.0
      : books.fold<int>(0, (total, book) => total + book.pages) / books.length,
);
