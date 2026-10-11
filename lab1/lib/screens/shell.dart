import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/meeting.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../widgets/confirm.dart';
import 'favourites_tab.dart';
import 'meetings_tab.dart';
import 'profile_tab.dart';

class Shell extends StatefulWidget {
  const Shell({super.key, required this.themeMode, required this.onThemeChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<Meeting> _meetings = seedMeetings();
  Profile _profile = const Profile.empty();
  int _tab = 0;
  int _resetVersion = 0;

  void _selectTab(int index) => setState(() => _tab = index);

  void _update(Meeting meeting) {
    setState(() {
      _meetings = _meetings.map((item) => item.id == meeting.id ? meeting : item).toList();
    });
  }

  void _delete(Meeting meeting) {
    setState(() {
      _meetings = _meetings.where((item) => item.id != meeting.id).toList();
    });
  }

  void _saveProfile(Profile profile) {
    final oldName = _profile.name;
    final meetings = _meetings.map((meeting) {
      if (oldName.isEmpty || !meeting.contains(oldName)) return meeting;
      return meeting.copyWith(names: meeting.names
          .map((name) => name == oldName ? profile.name : name).toSet().toList());
    }).toList();
    setState(() {
      _meetings = meetings;
      _profile = profile;
    });
  }

  void _open(Meeting meeting) {
    Navigator.pushNamed<void>(context, Routes.detail, arguments: DetailArguments(
      meeting: meeting,
      profile: _profile,
      onChanged: _update,
      onDelete: _delete,
      onProfile: () => _selectTab(2),
    ));
  }

  Future<void> _create() async {
    final meeting = await Navigator.pushNamed<Meeting>(
      context, Routes.form, arguments: const FormArguments(),
    );
    if (!mounted || meeting == null) return;
    setState(() => _meetings = [..._meetings, meeting]);
  }

  void _about() {
    Navigator.pop(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Study Together'),
        content: const Text('Find a study meeting, save a favourite and join your classmates. Each meeting lasts one hour. Data stays in memory until the app restarts.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _reset() async {
    Navigator.pop(context);
    final accepted = await confirm(context,
      title: 'Reset data?',
      message: 'Restore the 12 example meetings and clear your profile?',
      action: 'Reset',
    );
    if (!mounted || accepted != true) return;
    setState(() {
      _meetings = seedMeetings();
      _profile = const Profile.empty();
      _tab = 0;
      _resetVersion++;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(['Study Together', 'Favourites', 'Profile'][_tab])),
    drawer: Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Study Together', style: Theme.of(context).textTheme.headlineSmall),
            ),
            const Divider(),
            ListTile(title: const Text('About'), onTap: _about),
            ListTile(title: const Text('Reset data'), onTap: _reset),
          ],
        ),
      ),
    ),
    body: SafeArea(
      child: IndexedStack(
        key: ValueKey(_resetVersion),
        index: _tab,
        children: [
          MeetingsTab(meetings: _meetings, onOpen: _open, onFavourite: (meeting) => _update(meeting.copyWith(favourite: !meeting.favourite))),
          FavouritesTab(meetings: _meetings, onOpen: _open, onFavourite: (meeting) => _update(meeting.copyWith(favourite: !meeting.favourite)), onBrowse: () => _selectTab(0)),
          ProfileTab(profile: _profile, meetings: _meetings, onChanged: _saveProfile, themeMode: widget.themeMode, onThemeChanged: widget.onThemeChanged),
        ],
      ),
    ),
    floatingActionButton: _tab == 2 ? null : FloatingActionButton(
      onPressed: _create,
      tooltip: 'New meeting',
      child: const Icon(Icons.add),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: _selectTab,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Meetings'),
        NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favourites'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    ),
  );
}
