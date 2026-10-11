import 'package:flutter/material.dart';

import 'models/meeting.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/meeting_form.dart';
import 'screens/shell.dart';
import 'widgets/empty_state.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeData _theme(Brightness brightness) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const ColorScheme.light().primary,
      brightness: brightness,
    ),
    useMaterial3: true,
  );

  Route<dynamic> _notFound(RouteSettings settings) => MaterialPageRoute<void>(
    settings: settings,
    builder: (context) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const EmptyState(icon: Icons.error_outline, message: 'Not found'),
    ),
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Study Together',
    debugShowCheckedModeBanner: false,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: _themeMode,
    routes: {
      Routes.home: (context) => Shell(
        themeMode: _themeMode,
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    },
    onGenerateRoute: (settings) => switch ((settings.name, settings.arguments)) {
      (Routes.detail, final DetailArguments args) => MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => DetailScreen(arguments: args),
      ),
      (Routes.form, final FormArguments args) => MaterialPageRoute<Meeting>(
        settings: settings,
        builder: (context) => MeetingForm(meeting: args.meeting),
      ),
      _ => null,
    },
    onUnknownRoute: _notFound,
  );
}
