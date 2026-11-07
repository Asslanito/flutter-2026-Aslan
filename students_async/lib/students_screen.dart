import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

/// Levels 2 and 5: the four states by hand, plus Save.
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students; // null = not loaded yet
  Object? _error; // non-null = failed
  final _api = FakeApi(); // use FakeApi(empty: true) to see the empty state
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load(); // initState is synchronous: call, do not await
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _save() async {
    final n = _students!.length;
    setState(() => _saving = true);
    try {
      await _api.save(n);
      if (!mounted) return;
      Navigator.pop(context); // pop only on success
    } on StateError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_error != null) {
      body = ErrorView(onRetry: _load);
    } else if (_students == null) {
      body = const LoadingView();
    } else if (_students!.isEmpty) {
      body = const EmptyView();
    } else {
      body = StudentList(_students!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Students (by hand)')),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: (_saving || _students == null) ? null : _save,
        child: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
      ),
    );
  }
}
