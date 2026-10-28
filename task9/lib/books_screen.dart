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
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
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
          return ListTile(
            title: Text(book.title),
            subtitle: Text('${book.author} · ${book.price} ₸'),
            trailing: isAdded
                ? const Text('Added')
                : OutlinedButton(
                    onPressed: () {
                      final added = context.read<Cart>().add(book);
                      if (added) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Added')));
                      }
                    },
                    child: const Text('Add'),
                  ),
          );
        },
      ),
    );
  }
}
