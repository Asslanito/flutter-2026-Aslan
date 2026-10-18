import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_title, _author, _pages, _year]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate() == false) return;
    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text.trim()),
      year: int.tryParse(_year.text.trim()),
    );
    Navigator.of(context).pop(book);
  }

  void _dismiss(PointerDownEvent event) =>
      FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add book')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onTapOutside: _dismiss,
                validator: (value) => (value ?? '').trim().length < 2
                    ? 'At least 2 characters'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _author,
                decoration: const InputDecoration(labelText: 'Author'),
                textInputAction: TextInputAction.next,
                onTapOutside: _dismiss,
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Enter an author' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pages,
                decoration: const InputDecoration(labelText: 'Pages'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onTapOutside: _dismiss,
                validator: (value) {
                  final pages = int.tryParse((value ?? '').trim());
                  return pages == null || pages <= 0
                      ? 'A whole number above 0'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _year,
                decoration: const InputDecoration(labelText: 'Year (optional)'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onTapOutside: _dismiss,
                onFieldSubmitted: (_) => _save(),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return null;
                  final year = int.tryParse(text);
                  return year == null ||
                          year < 1450 ||
                          year > DateTime.now().year
                      ? 'Use a year from 1450 to ${DateTime.now().year}'
                      : null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    ),
  );
}
