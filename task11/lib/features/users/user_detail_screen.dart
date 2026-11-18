import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    final site = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _row('ID', '${user.id}'),
          _row('Username', user.username),
          _row('Email', user.email),
          ListTile(
            title: const Text('Phone'),
            subtitle: Text('${user.phone}  (${user.phoneDigits})'),
            onTap: () {}, // Practice 12: url_launcher
          ),
          ListTile(
            title: const Text('Website'),
            subtitle: Text(site ?? '—'),
            onTap: site == null ? null : () {}, // Practice 12
          ),
          _row('Address', '${a.street}, ${a.suite}\n${a.city} ${a.zipcode}'),
          _row('Geo', '${a.geo.lat}, ${a.geo.lng}'),
          _row('Company', '${user.company.name}\n${user.company.catchPhrase}'),
        ],
      ),
    );
  }

  Widget _row(String k, String v) =>
      ListTile(title: Text(k), subtitle: Text(v));
}
