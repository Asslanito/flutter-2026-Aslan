import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [
    for (final book in seed)
      Book(
        title: book.title,
        author: book.author,
        pages: book.pages,
        year: book.year,
        read: book.read,
      ),
  ];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((book) => book.read).toList(),
  };

  Future<void> _open(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute(builder: (_) => DetailScreen(book: book)),
    );
    if (mounted == false) return;
    switch (action) {
      case null:
        return;
      case BookAction.toggleRead:
        setState(() => book.read = book.read == false);
      case BookAction.delete:
        setState(() => _books.remove(book));
    }
  }

  Future<void> _add() async {
    final book = await Navigator.of(context)
        .push<Book>(MaterialPageRoute(builder: (_) => const AddBookScreen()));
    if (book == null || mounted == false) return;
    setState(() => _books.add(book));
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${visible.length})')),
      body: SafeArea(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    for (final item in [
                      (label: 'Books', value: _books.length),
                      (label: 'Pages', value: totalPages(_books)),
                      (label: 'Unread', value: unread(_books).length),
                    ])
                      Expanded(
                        child: Column(
                          children: [
                            Text('${item.value}', style: text.headlineSmall),
                            Text(item.label, style: text.bodySmall),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                for (final filter in Filter.values)
                  ChoiceChip(
                    label: Text(switch (filter) {
                      Filter.all => 'All',
                      Filter.unread => 'Unread',
                      Filter.read => 'Read',
                    }),
                    selected: filter == _filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
              ],
            ),
            Expanded(
              child: visible.isEmpty
                  ? const Center(child: Text('No books in this filter'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final book = visible[index];
                        return BookTile(
                          book: book,
                          onOpen: () => _open(book),
                          onToggle: () =>
                              setState(() => book.read = book.read == false),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        tooltip: 'Add book',
        child: const Icon(Icons.add),
      ),
    );
  }
}
