import 'package:flutter/material.dart';

import '../models/meeting.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.meetings,
    required this.onChanged,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final Profile profile;
  final List<Meeting> meetings;
  final ValueChanged<Profile> onChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _group;
  final _nameFocus = FocusNode();
  final _groupFocus = FocusNode();
  final _groupPattern = RegExp(r'^[A-Z]{2,6}-\d{2,4}$');

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.name != widget.profile.name) _name.text = widget.profile.name;
    if (oldWidget.profile.group != widget.profile.group) _group.text = widget.profile.group;
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _nameFocus.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onChanged(widget.profile.copyWith(
      name: _name.text.trim(),
      group: _group.text.trim().toUpperCase(),
    ));
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    final joined = widget.meetings.fold<int>(
      0,
      (total, meeting) => total + (meeting.contains(widget.profile.name) ? 1 : 0),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.school_outlined, size: 56),
                const SizedBox(height: 12),
                Text('Your study profile', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('You are on $joined lists', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _name,
                  focusNode: _nameFocus,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  maxLength: 40,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  validator: (value) => (value ?? '').trim().length < 2 ? 'Enter at least 2 characters' : null,
                  onFieldSubmitted: (_) {
                    _save();
                    _groupFocus.requestFocus();
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _group,
                  focusNode: _groupFocus,
                  decoration: const InputDecoration(labelText: 'Group', hintText: 'IT-2201', border: OutlineInputBorder()),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  validator: (value) => _groupPattern.hasMatch((value ?? '').trim().toUpperCase()) ? null : 'Use a group like IT-2201',
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _save, child: const Text('Save profile')),
                const SizedBox(height: 32),
                Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final mode in ThemeMode.values)
                      ChoiceChip(
                        label: Text(switch (mode) {
                          ThemeMode.system => 'System',
                          ThemeMode.light => 'Light',
                          ThemeMode.dark => 'Dark',
                        }),
                        selected: widget.themeMode == mode,
                        onSelected: (_) => widget.onThemeChanged(mode),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Meetings and your profile are kept in memory for this session.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
