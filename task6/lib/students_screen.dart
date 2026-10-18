import 'package:flutter/material.dart';

import 'routes.dart';
import 'students.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Students')),
    body: ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return ListTile(
          leading: CircleAvatar(child: Text(student.name.substring(0, 1))),
          title: Text(student.name),
          subtitle: Text(student.group),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              Navigator.of(context)
                  .pushNamed<void>(Routes.student, arguments: student),
        );
      },
    ),
  );
}
