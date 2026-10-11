import 'package:flutter/material.dart';

import '../models/meeting.dart';
import '../widgets/empty_state.dart';
import '../widgets/meeting_list.dart';
import 'meetings_tab.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.meetings,
    required this.onOpen,
    required this.onFavourite,
    required this.onBrowse,
  });

  final List<Meeting> meetings;
  final ValueChanged<Meeting> onOpen;
  final ValueChanged<Meeting> onFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = meetings.where((meeting) => meeting.favourite).toList()
      ..sort(compareMeetings);

    return favourites.isEmpty
        ? EmptyState(
            icon: Icons.favorite_border,
            message: 'Your favourite meetings will appear here.',
            buttonLabel: 'Browse meetings',
            onPressed: onBrowse,
          )
        : MeetingList(meetings: favourites, onOpen: onOpen, onFavourite: onFavourite);
  }
}
