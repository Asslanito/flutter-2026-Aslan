import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final auth = context.read<AuthModel>();
    final nav = Navigator.of(context);
    await auth.logout();
    nav.popUntil((r) => r.isFirst); // reveals the login screen
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsModel>();
    final cities = context.watch<UsersModel>().cities;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: s.dark,
            onChanged: s.setDark,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              key: ValueKey(s.city),
              initialValue: cities.contains(s.city) ? s.city : null,
              decoration: const InputDecoration(labelText: 'City filter'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All cities'),
                ),
                for (final c in cities)
                  DropdownMenuItem<String?>(value: c, child: Text(c)),
              ],
              onChanged: s.setCity,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
