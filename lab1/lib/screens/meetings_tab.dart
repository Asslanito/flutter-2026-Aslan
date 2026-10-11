import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/meeting.dart';
import '../widgets/empty_state.dart';
import '../widgets/meeting_list.dart';

class MeetingsTab extends StatefulWidget {
  const MeetingsTab({
    super.key,
    required this.meetings,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Meeting> meetings;
  final ValueChanged<Meeting> onOpen;
  final ValueChanged<Meeting> onFavourite;

  @override
  State<MeetingsTab> createState() => _MeetingsTabState();
}

class _MeetingsTabState extends State<MeetingsTab> {
  final _search = TextEditingController();
  Category? _category;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clear() {
    _search.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final meetings = widget.meetings.where((meeting) {
      return meeting.title.toLowerCase().contains(query) &&
          (_category == null || meeting.category == _category) &&
          (_showPast || !meeting.isPast);
    }).toList()..sort(compareMeetings);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              labelText: 'Find a study meeting',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty ? null : IconButton(
                tooltip: 'Clear search',
                onPressed: _clear,
                icon: const Icon(Icons.clear),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final category in Category.values)
                ChoiceChip(
                  avatar: Icon(category.icon, color: category.color(Theme.of(context).colorScheme)),
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilterChip(
            label: const Text('Include past meetings'),
            selected: _showPast,
            onSelected: (value) => setState(() => _showPast = value),
          ),
        ),
        Expanded(
          child: meetings.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No meetings match these filters.',
                  buttonLabel: 'Clear search',
                  onPressed: _clear,
                )
              : MeetingList(meetings: meetings, onOpen: widget.onOpen, onFavourite: widget.onFavourite),
        ),
      ],
    );
  }
}

int compareMeetings(Meeting a, Meeting b) {
  if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
  return a.when.compareTo(b.when);
}
