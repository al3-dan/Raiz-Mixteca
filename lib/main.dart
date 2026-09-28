import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'pages/lotes_page.dart';
import 'pages/productores_page.dart';
import 'pages/productos_page.dart';
import 'pages/qr_escanear_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;

  runApp(const RaizMixtecaApp());
}

class RaizMixtecaApp extends StatelessWidget {
  const RaizMixtecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RaízMixteca',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RaízMixteca')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            const Icon(Icons.eco, size: 80),

            const SizedBox(height: 20),

            const Text(
              'RaízMixteca',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'Productos artesanales y trazabilidad de la región Mixteca',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 40),

            _MenuButton(
              icon: Icons.people,
              title: 'Productores',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductoresPage()),
                );
              },
            ),

            const SizedBox(height: 15),

            _MenuButton(
              icon: Icons.inventory_2,
              title: 'Productos',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductosPage()),
                );
              },
            ),

            const SizedBox(height: 15),

            _MenuButton(
              icon: Icons.qr_code_2,
              title: 'Lotes y trazabilidad',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LotesPage()),
                );
              },
            ),

            const SizedBox(height: 15),

            _MenuButton(
              icon: Icons.camera_alt,
              title: 'Escanear QR',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QrEscanearPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title, style: const TextStyle(fontSize: 17)),
      ),
    );
  }
}
