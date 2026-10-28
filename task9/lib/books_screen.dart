import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final query = _searchText.trim().toLowerCase();
    final filteredBooks = books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const ValueKey('book-search'),
          decoration: const InputDecoration(
            hintText: 'Search books',
            prefixIcon: Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) => setState(() => _searchText = value),
        ),
        actions: const [CartBadge()],
      ),
      body: ListView.builder(
        itemCount: filteredBooks.length,
        itemBuilder: (context, index) {
          final book = filteredBooks[index];
          debugPrint('row ${book.title}');
          final isAdded = context.watch<Cart>().items.contains(book);
          return Card(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            elevation: 0,
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${book.author} · ${book.price} ₸'),
              ),
              trailing: isAdded
                  ? const Text('Added')
                  : OutlinedButton(
                      onPressed: () {
                        final added = context.read<Cart>().add(book);
                        if (added) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added')),
                          );
                        }
                      },
                      child: const Text('Add'),
                    ),
            ),
          );
        },
      ),
    );
  }
}
