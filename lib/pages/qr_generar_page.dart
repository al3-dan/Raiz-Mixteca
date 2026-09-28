import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/lote.dart';

class QrGenerarPage extends StatelessWidget {
  final Lote lote;

  const QrGenerarPage({super.key, required this.lote});

  String get _qrValue => 'https://raizmixteca.example/lote/${lote.codigoLote}';

  Future<void> _compartirQr(BuildContext context) async {
    try {
      await Share.share(
        '$_qrValue\n\nLote: ${lote.codigoLote}',
        subject: 'Código QR del lote ${lote.codigoLote}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo compartir el QR: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR ${lote.codigoLote}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: QrImageView(
                  data: _qrValue,
                  version: QrVersions.auto,
                  size: 240,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              lote.codigoLote,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _qrValue,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _compartirQr(context),
              icon: const Icon(Icons.share),
              label: const Text('COMPARTIR QR'),
            ),
          ],
        ),
      ),
    );
  }
}
