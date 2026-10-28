import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Remove all books from the cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed == true) context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cart'),
      actions: [
        TextButton(
          onPressed: () => _confirmClear(context),
          child: const Text('Clear cart'),
        ),
      ],
    ),
    body: Consumer<Cart>(
      builder: (context, cart, _) => Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 56,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your cart is empty',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final book = cart.items[index];
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
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Text('×${cart.qtyOf(book)}'),
                          ),
                          title: Text(book.title),
                          subtitle: Text('${book.price} ₸ each'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Add one',
                                onPressed: () => cart.increment(book),
                                icon: const Icon(Icons.add),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                onPressed: () => cart.remove(book),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Consumer<Cart>(
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined),
                SizedBox(width: 8),
                Text('Total'),
              ],
            ),
            builder: (context, currentCart, child) => Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  child!,
                  const SizedBox(width: 12),
                  Text(
                    '${currentCart.total} ₸',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
