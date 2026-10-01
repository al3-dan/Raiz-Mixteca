import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../repositories/lote_repository.dart';
import 'qr_publica_page.dart';

class QrEscanearPage extends StatefulWidget {
  const QrEscanearPage({super.key});

  @override
  State<QrEscanearPage> createState() => _QrEscanearPageState();
}

class _QrEscanearPageState extends State<QrEscanearPage>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  static const colorTerracota = Color(0xFFB85C38);
  static const colorCrema = Color(0xFFF5F0E7);
  static const colorCafe = Color(0xFF211B17);
  static const colorVerde = Color(0xFF50634A);
  static const colorDorado = Color(0xFFD99A32);

  bool _procesando = false;
  bool _errorMostrado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_procesando) {
      _controller.start();
    }

    if (state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }

  Future<void> _procesarCodigo(String? valor) async {
    if (valor == null || !mounted || _procesando) {
      return;
    }

    final codigo = LoteRepository.extraerCodigoLote(valor);

    if (codigo == null) {
      if (!_errorMostrado && mounted) {
        _errorMostrado = true;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'QR no reconocido. Escanea el código de un lote de RaízMixteca.',
            ),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          _errorMostrado = false;
        });
      }

      return;
    }

    setState(() {
      _procesando = true;
    });

    await _controller.stop();

    if (!mounted) return;

    final lote = await LoteRepository().obtenerPorCodigo(codigo);

    if (!mounted) return;

    if (lote == null) {
      setState(() {
        _procesando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró ningún lote con ese identificador.'),
        ),
      );

      await _controller.start();
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QrPublicaPage(codigoLote: lote.codigoLote),
      ),
    );
  }

  Future<void> _activarLinterna() async {
    await _controller.toggleTorch();
  }

  Future<void> _cambiarCamara() async {
    await _controller.switchCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorCafe,
      body: Stack(
        children: [
          // ==================================================
          // CÁMARA
          // ==================================================
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final code = capture.barcodes.firstOrNull?.rawValue;

                if (code != null) {
                  _procesarCodigo(code);
                }
              },
            ),
          ),

          // ==================================================
          // OSCURECIMIENTO
          // ==================================================
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ScannerOverlayPainter()),
            ),
          ),

          // ==================================================
          // PARTE SUPERIOR
          // ==================================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Escanear QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _activarLinterna,
                      icon: const Icon(
                        Icons.flashlight_on_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _cambiarCamara,
                      icon: const Icon(
                        Icons.cameraswitch_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==================================================
          // INSTRUCCIONES
          // ==================================================
          Positioned(
            top: 125,
            left: 30,
            right: 30,
            child: Column(
              children: [
                const Text(
                  'Descubre el origen de tu producto',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coloca el código QR dentro del marco',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // MARCO CENTRAL
          // ==================================================
          Center(
            child: SizedBox(
              width: 270,
              height: 270,
              child: Stack(
                children: [
                  // Esquinas
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _esquina(arriba: true, izquierda: true),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _esquina(arriba: true, izquierda: false),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _esquina(arriba: false, izquierda: true),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _esquina(arriba: false, izquierda: false),
                  ),

                  // Línea de escaneo
                  if (!_procesando)
                    Positioned(
                      left: 15,
                      right: 15,
                      top: 130,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: colorDorado,
                          boxShadow: [
                            BoxShadow(
                              color: colorDorado.withOpacity(0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ==================================================
          // ESTADO DE PROCESAMIENTO
          // ==================================================
          if (_procesando)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colorDorado),
                    SizedBox(height: 14),
                    Text(
                      'Buscando información...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ==================================================
          // TARJETA INFERIOR
          // ==================================================
          Positioned(
            left: 20,
            right: 20,
            bottom: 25,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorCrema,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorTerracota.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        color: colorTerracota,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 13),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trazabilidad RaízMixteca',
                            style: TextStyle(
                              color: colorCafe,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Conoce quién lo produjo y cómo llegó hasta ti.',
                            style: TextStyle(
                              color: colorCafe,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _esquina({required bool arriba, required bool izquierda}) {
    return SizedBox(
      width: 42,
      height: 42,
      child: CustomPaint(
        painter: _CornerPainter(
          arriba: arriba,
          izquierda: izquierda,
          color: colorDorado,
        ),
      ),
    );
  }
}

// ============================================================
// OVERLAY DEL ESCÁNER
// ============================================================

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.52)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const scannerSize = 270.0;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: scannerSize,
        height: scannerSize,
      ),
      const Radius.circular(20),
    );

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(rect),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// ESQUINAS DEL MARCO
// ============================================================

class _CornerPainter extends CustomPainter {
  final bool arriba;
  final bool izquierda;
  final Color color;

  _CornerPainter({
    required this.arriba,
    required this.izquierda,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (arriba && izquierda) {
      path.moveTo(2, size.height * 0.75);
      path.lineTo(2, 2);
      path.lineTo(size.width * 0.75, 2);
    } else if (arriba && !izquierda) {
      path.moveTo(size.width * 0.25, 2);
      path.lineTo(size.width - 2, 2);
      path.lineTo(size.width - 2, size.height * 0.75);
    } else if (!arriba && izquierda) {
      path.moveTo(2, size.height * 0.25);
      path.lineTo(2, size.height - 2);
      path.lineTo(size.width * 0.75, size.height - 2);
    } else {
      path.moveTo(size.width * 0.25, size.height - 2);
      path.lineTo(size.width - 2, size.height - 2);
      path.lineTo(size.width - 2, size.height * 0.25);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.arriba != arriba ||
        oldDelegate.izquierda != izquierda;
  }
}
