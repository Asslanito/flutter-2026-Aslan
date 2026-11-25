import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // before any plugin

  // Read the disk BEFORE the first frame: no flash of the wrong theme.
  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter'); // String?
  final avatarPath = await prefs.getString('avatarPath'); // String?

  final store = SecureStore();
  final token = await store.readToken();

  final api = ApiClient.live(store);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => SettingsModel(
          prefs,
          dark: dark,
          city: city,
          avatarPath: avatarPath,
        ),
      ),
      ChangeNotifierProvider(create: (_) => AuthModel(store, token: token)),
      ChangeNotifierProvider(
        create: (_) => UsersModel(UserRepository(api, UsersCache()))..load(),
      ),
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.select<SettingsModel, bool>((s) => s.dark);
    final signedIn = context.select<AuthModel, bool>((a) => a.signedIn);
    return MaterialApp(
      title: 'Users API',
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: signedIn ? const UsersScreen() : const LoginScreen(),
    );
  }
}
