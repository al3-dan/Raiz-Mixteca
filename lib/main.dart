import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'pages/main_navigation_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;

  runApp(const RaizMixtecaApp());
}

class RaizMixtecaApp extends StatelessWidget {
  const RaizMixtecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorTerracota = Color(0xFFB85C38);
    const colorCrema = Color(0xFFF5F0E7);
    const colorCafe = Color(0xFF211B17);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RaízMixteca',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: colorCrema,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorTerracota,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          foregroundColor: colorCafe,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: colorTerracota, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorTerracota,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: colorTerracota,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainNavigationPage(),
    );
  }
}
