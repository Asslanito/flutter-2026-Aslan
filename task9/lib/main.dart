import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'books_screen.dart';
import 'cart_screen.dart';
import 'models/cart.dart';

void main() =>
    runApp(ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()));

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Bookshop',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFB85C38),
        surface: const Color(0xFFFFFDF9),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F1EA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F1EA),
        foregroundColor: Color(0xFF292524),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      useMaterial3: true,
    ),
    routes: {
      '/': (_) => const BooksScreen(),
      '/cart': (_) => const CartScreen(),
    },
  );
}
