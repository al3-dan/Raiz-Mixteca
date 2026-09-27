import 'package:flutter/material.dart';

import 'database/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await DatabaseHelper.instance.database;

  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master "
    "WHERE type = 'table' "
    "ORDER BY name",
  );

  debugPrint('TABLAS SQLITE: $tables');

  runApp(const RaizMixtecaApp());
}

class RaizMixtecaApp extends StatelessWidget {
  const RaizMixtecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RaízMixteca',
      home: Scaffold(
        appBar: AppBar(title: const Text('RaízMixteca')),
        body: const Center(
          child: Text(
            'Base de datos SQLite conectada',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
