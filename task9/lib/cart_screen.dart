import 'package:flutter/material.dart';

import 'models/book.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.items, required this.onRemove});

  final List<Book> items;
  final void Function(Book) onRemove;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  for (final book in items)
                    ListTile(
                      title: Text(book.title),
                      subtitle: Text('${book.price} ₸'),
                      trailing: IconButton(
                        tooltip: 'Remove',
                        onPressed: () => onRemove(book),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Total: ${items.fold(0, (sum, book) => sum + book.price)} ₸',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      );
}
