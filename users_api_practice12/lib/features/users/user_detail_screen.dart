import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_model.dart';
import 'user.dart';

Future<void> _open(BuildContext context, Uri uri) async {
  final messenger = ScaffoldMessenger.of(context);
  final ok = await launchUrl(uri);
  if (!ok) {
    messenger.showSnackBar(
      const SnackBar(content: Text('No app can open this')),
    );
  }
}

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
          ListTile(
            title: const Text('Email'),
            subtitle: Text(user.email),
            onTap: () => _open(
              context,
              Uri(scheme: 'mailto', path: user.email),
            ),
          ),
          ListTile(
            title: const Text('Phone'),
            subtitle: Text(user.phone),
            onTap: () => _open(
              context,
              Uri(scheme: 'tel', path: user.phoneDigits),
            ),
          ),
          ListTile(
            title: const Text('Website'),
            subtitle: Text(site ?? '—'),
            onTap: site == null
                ? null
                : () => _open(
                      context,
                      Uri.parse(
                        site.startsWith('http') ? site : 'https://$site',
                      ),
                    ),
          ),
          _row('Address', '${a.street}, ${a.suite}\n${a.city} ${a.zipcode}'),
          _row('Geo', '${a.geo.lat}, ${a.geo.lng}'),
          _row('Company', '${user.company.name}\n${user.company.catchPhrase}'),
          if (kDebugMode)
            TextButton(
              onPressed: () async {
                final auth = context.read<AuthModel>();
                final t = await auth.debugToken();
                if (t != null) await Clipboard.setData(ClipboardData(text: t));
              },
              child: const Text('Copy token to clipboard (debug)'),
            ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) =>
      ListTile(title: Text(k), subtitle: Text(v));
}
