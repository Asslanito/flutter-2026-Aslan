import 'package:flutter/material.dart';

String formatBirth(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birth,
  });

  final String name;
  final String email;
  final String group;
  final DateTime? birth;

  @override
  Widget build(BuildContext context) => Card(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final date = birth;
        final tiles = [
          ListTile(title: const Text('Name'), subtitle: Text(name)),
          ListTile(title: const Text('Email'), subtitle: Text(email)),
          ListTile(title: const Text('Group'), subtitle: Text(group)),
          ListTile(
            title: const Text('Date of birth'),
            subtitle: Text(date == null ? 'Not selected' : formatBirth(date)),
          ),
        ];
        return constraints.maxWidth >= 600
            ? GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 4,
                children: tiles,
              )
            : Column(children: tiles);
      },
    ),
  );
}
