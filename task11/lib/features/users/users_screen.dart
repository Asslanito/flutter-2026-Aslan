import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();

    final Widget body = m.loading
        ? const LoadingView()
        : switch (m.error) {
            null => UserList(items: m.items),
            NoConnectionException() => Offline(onRetry: m.load),
            NotFoundException() || UnauthorizedException() => _Message(
                icon: Icons.block,
                title: 'The server rejected the request.',
                onRetry: m.load,
              ),
            ServerException(:final status) =>
              ServerError(status, onRetry: m.load),
            BadResponseException() => const GenericError(),
          };

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: RefreshIndicator(onRefresh: m.load, child: body),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({super.key, required this.items});

  final List<User> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final u = items[i];
        return ListTile(
          title: Text(u.name),
          subtitle: Text('${u.email} · ${u.address.city}'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => UserDetailScreen(user: u)),
          ),
        );
      },
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const _Scrollable(child: CircularProgressIndicator());
}

class Offline extends StatelessWidget {
  const Offline({super.key, required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => _Message(
        icon: Icons.wifi_off,
        title: 'No connection',
        onRetry: onRetry,
      );
}

class ServerError extends StatelessWidget {
  const ServerError(this.status, {super.key, required this.onRetry});
  final int status;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => _Message(
        icon: Icons.cloud_off,
        title: 'Server error ($status)',
        onRetry: onRetry,
      );
}

class GenericError extends StatelessWidget {
  const GenericError({super.key});

  @override
  Widget build(BuildContext context) => const _Message(
        icon: Icons.bug_report_outlined,
        title: 'The server sent something we could not read.',
      );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, this.onRetry});

  final IconData icon;
  final String title;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return _Scrollable(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center),
          if (retry != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: retry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

// Scrollable so pull-to-refresh also works on empty / error views.
class _Scrollable extends StatelessWidget {
  const _Scrollable({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }
}
