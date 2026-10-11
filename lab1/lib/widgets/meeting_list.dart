import 'package:flutter/material.dart';

import '../models/meeting.dart';
import 'meeting_card.dart';

class MeetingList extends StatelessWidget {
  const MeetingList({
    super.key,
    required this.meetings,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Meeting> meetings;
  final ValueChanged<Meeting> onOpen;
  final ValueChanged<Meeting> onFavourite;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      Widget card(int index) {
        final meeting = meetings[index];
        return MeetingCard(
          meeting: meeting,
          onOpen: () => onOpen(meeting),
          onFavourite: () => onFavourite(meeting),
        );
      }

      if (constraints.maxWidth >= 600) {
        final columns = (constraints.maxWidth / 360).ceil();
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 204,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: meetings.length,
          itemBuilder: (context, index) => card(index),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: meetings.length,
        itemBuilder: (context, index) => card(index),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      );
    },
  );
}
