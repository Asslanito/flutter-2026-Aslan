import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/meeting.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm.dart';
import '../widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.arguments});
  final DetailArguments arguments;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Meeting _meeting;
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _meeting = widget.arguments.meeting;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _update(Meeting meeting) {
    widget.arguments.onChanged(meeting);
    setState(() => _meeting = meeting);
  }

  Future<void> _edit() async {
    final meeting = await Navigator.pushNamed<Meeting>(
      context, Routes.form, arguments: FormArguments(meeting: _meeting),
    );
    if (!mounted || meeting == null) return;
    _update(meeting);
  }

  Future<void> _delete() async {
    final accepted = await confirm(context,
      title: 'Delete meeting?', message: _meeting.title, action: 'Delete',
    );
    if (!mounted || accepted != true) return;
    widget.arguments.onDelete(_meeting);
    Navigator.pop(context);
  }

  Future<void> _joinOrLeave() async {
    final name = widget.arguments.profile.name;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Save your name in Profile first.'),
        action: SnackBarAction(label: 'Profile', onPressed: () {
          if (!mounted) return;
          widget.arguments.onProfile();
          Navigator.pop(context);
        }),
      ));
      return;
    }

    final joined = _meeting.contains(name);
    if (joined) {
      _update(_meeting.copyWith(names: _meeting.names.where((person) => person != name).toList()));
      return;
    }
    if (_meeting.isFull || _meeting.isPast) return;
    final accepted = await confirm(context,
      title: 'Join this meeting?',
      message: 'Add $name to ${_meeting.title}?',
      action: 'Join',
    );
    if (!mounted || accepted != true) return;
    if (_meeting.isPast || _meeting.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This meeting is no longer open.')));
      return;
    }
    _update(_meeting.copyWith(names: [..._meeting.names, name]));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final joined = _meeting.contains(widget.arguments.profile.name);
    final (:taken, :free) = _meeting.places;
    final closed = _meeting.isFull || _meeting.isPast;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Study meeting'),
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Meeting options',
              onSelected: (value) {
                switch (value) {
                  case 'edit': _edit();
                  case 'delete': _delete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 3,
                      child: Image.asset('assets/study.png', fit: BoxFit.cover, semanticLabel: 'Study meeting banner'),
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: scheme.surface,
                      child: Icon(_meeting.category.icon, size: 32, color: _meeting.category.color(scheme)),
                    ),
                    Positioned(left: 12, top: 8, child: Chip(label: Text(_meeting.category.label))),
                    Positioned(right: 12, bottom: 8, child: Chip(label: Text(countdownLabel(Countdown.at(_meeting.when, _now))))),
                  ],
                ),
              ),
              TabBar(tabs: [const Tab(text: 'About'), Tab(text: 'Members ($taken)')]),
              Expanded(
                child: TabBarView(children: [
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(_meeting.title, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 20),
                      Text(formatDateTime(_meeting.when)),
                      const SizedBox(height: 12),
                      Text('${_meeting.online ? 'Online link' : 'Place'}: ${_meeting.place}'),
                      const SizedBox(height: 12),
                      Text('$taken joined · $free free · Limit ${_meeting.limit}'),
                      if (_meeting.description case final description?) ...[
                        const SizedBox(height: 20),
                        Text(description),
                      ],
                    ],
                  ),
                  _meeting.names.isEmpty
                      ? const EmptyState(icon: Icons.people_outline, message: 'Nobody has joined yet.')
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            for (final name in _meeting.names)
                              ListTile(
                                title: Text(name),
                                selected: name == widget.arguments.profile.name,
                                selectedTileColor: scheme.secondaryContainer,
                                trailing: name == widget.arguments.profile.name ? const Chip(label: Text('You')) : null,
                              ),
                          ],
                        ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: !joined && closed ? null : _joinOrLeave,
                    icon: Icon(joined ? Icons.exit_to_app : Icons.person_add_outlined),
                    label: Text(joined ? 'Leave meeting' : _meeting.isPast ? 'Meeting started' : _meeting.isFull ? 'Meeting full' : 'Join meeting'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
