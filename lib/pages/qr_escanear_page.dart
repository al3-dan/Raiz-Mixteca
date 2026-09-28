import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../repositories/lote_repository.dart';
import 'qr_publica_page.dart';

class QrEscanearPage extends StatefulWidget {
  const QrEscanearPage({super.key});

  @override
  State<QrEscanearPage> createState() => _QrEscanearPageState();
}

class _QrEscanearPageState extends State<QrEscanearPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _errorMostrado = false;

  Future<void> _procesarCodigo(String? valor) async {
    if (valor == null || !mounted) {
      return;
    }

    final codigo = LoteRepository.extraerCodigoLote(valor);
    if (codigo == null) {
      if (!_errorMostrado) {
        _errorMostrado = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Código QR no reconocido. Debe corresponder a un lote válido en el formato LOT-000001.',
            ),
          ),
        );
      }
      return;
    }

    _controller.stop();

    if (!mounted) return;

    final lote = await LoteRepository().obtenerPorCodigo(codigo);
    if (!mounted) return;

    if (lote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró ningún lote con ese identificador.'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QrPublicaPage(codigoLote: lote.codigoLote),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR del lote')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final code = capture.barcodes.firstOrNull?.rawValue;
              if (code != null) {
                _procesarCodigo(code);
              }
            },
          ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Apunta la cámara al código QR del lote.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
