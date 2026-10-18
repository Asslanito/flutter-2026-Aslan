import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _delete(BuildContext context) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (context.mounted == false || accepted == false || accepted == null) {
      return;
    }
    Navigator.of(context).pop(BookAction.delete);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(book.title)),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
          ListTile(title: const Text('Author'), subtitle: Text(book.author)),
          ListTile(title: const Text('Pages'), subtitle: Text('${book.pages}')),
          ListTile(
            title: const Text('Year'),
            subtitle: Text(book.year?.toString() ?? 'Year unknown'),
          ),
          ListTile(
            title: const Text('Status'),
            subtitle: Text(book.read ? 'Read' : 'Unread'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(BookAction.toggleRead),
            child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
          ),
          TextButton(
            onPressed: () => _delete(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    ),
  );
}
