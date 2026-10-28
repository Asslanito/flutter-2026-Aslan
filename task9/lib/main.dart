import 'package:flutter/material.dart';

import 'books_screen.dart';
import 'cart_screen.dart';
import 'models/book.dart';

void main() => runApp(const Shell());

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final List<Book> _cart = [];

  void _add(Book book) => setState(() => _cart.add(book));

  void _remove(Book book) => setState(() => _cart.remove(book));

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bookshop',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        routes: {
          '/': (_) => BooksScreen(
                cart: _cart,
                total: _cart.fold(0, (sum, book) => sum + book.price),
                onAdd: _add,
              ),
          '/cart': (_) => CartScreen(items: _cart, onRemove: _remove),
        },
      );
}
