import 'package:flutter/material.dart';

import 'students.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.student});

  final Student student;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late String _name = widget.student.name;
  bool _asking = false;

  bool get _dirty => _name != widget.student.name;

  Future<void> _onPop(bool didPop, String? result) async {
    if (didPop || _asking) return;
    _asking = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    _asking = false;
    if (discard == true) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => PopScope<String>(
    canPop: !_dirty,
    onPopInvokedWithResult: _onPop,
    child: Scaffold(
      appBar: AppBar(title: const Text('Edit student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'New name',
                hintText: widget.student.name,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onChanged: (value) => setState(() => _name = value),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              onSubmitted: (_) => Navigator.of(context).pop(_name),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_name),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    ),
  );
}
