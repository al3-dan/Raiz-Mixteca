import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/fotografia.dart';
import '../repositories/fotografia_repository.dart';

class FotografiasPage extends StatefulWidget {
  final int loteId;
  final String codigoLote;

  // true = productor propietario
  // false = visitante / otro productor
  final bool puedeEditar;

  const FotografiasPage({
    super.key,
    required this.loteId,
    required this.codigoLote,
    this.puedeEditar = true,
  });

  @override
  State<FotografiasPage> createState() => _FotografiasPageState();
}

class _FotografiasPageState extends State<FotografiasPage> {
  final _repository = FotografiaRepository();
  final _picker = ImagePicker();

  List<Fotografia> _fotografias = [];

  bool _cargando = true;
  bool _procesando = false;

  static const Color colorTierra = Color(0xFF6B4226);
  static const Color colorBarro = Color(0xFFA85D3A);
  static const Color colorVerde = Color(0xFF667C4A);
  static const Color colorDorado = Color(0xFFD5A84B);
  static const Color colorCrema = Color(0xFFF7F1E5);
  static const Color colorTexto = Color(0xFF30251F);

  @override
  void initState() {
    super.initState();
    _cargarFotografias();
  }

  Future<void> _cargarFotografias() async {
    try {
      final fotografias = await _repository.obtenerPorLote(widget.loteId);

      if (!mounted) return;

      setState(() {
        _fotografias = fotografias;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      _mostrarMensaje('No se pudieron cargar las fotografías: $e');
    }
  }

  Future<void> _seleccionarFuente() async {
    if (_procesando || !widget.puedeEditar) return;

    final fuente = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: colorCrema,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorTierra.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Agregar evidencia',
                  style: TextStyle(
                    color: colorTexto,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Selecciona cómo deseas agregar la fotografía.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _opcionFuente(
                        icono: Icons.camera_alt_outlined,
                        titulo: 'Cámara',
                        onTap: () {
                          Navigator.pop(context, ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _opcionFuente(
                        icono: Icons.photo_library_outlined,
                        titulo: 'Galería',
                        onTap: () {
                          Navigator.pop(context, ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || fuente == null) return;

    await _agregarFotografia(fuente);
  }

  Widget _opcionFuente({
    required IconData icono,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorTierra.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorTierra.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icono, color: colorTierra, size: 27),
              ),
              const SizedBox(height: 10),
              Text(
                titulo,
                style: const TextStyle(
                  color: colorTexto,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _agregarFotografia(ImageSource fuente) async {
    if (_procesando || !widget.puedeEditar) return;

    setState(() {
      _procesando = true;
    });

    try {
      final imagen = await _picker.pickImage(source: fuente, imageQuality: 85);

      if (imagen == null) {
        if (mounted) {
          setState(() {
            _procesando = false;
          });
        }
        return;
      }

      final fotografia = Fotografia(
        loteId: widget.loteId,
        ruta: imagen.path,
        descripcion: 'Fotografía del lote ${widget.codigoLote}',
      );

      await _repository.insertar(fotografia);

      if (!mounted) return;

      await _cargarFotografias();

      if (!mounted) return;

      _mostrarMensaje('Fotografía agregada correctamente.');
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje('No se pudo agregar la fotografía: $e');
    } finally {
      if (mounted) {
        setState(() {
          _procesando = false;
        });
      }
    }
  }

  Future<void> _eliminarFotografia(Fotografia fotografia) async {
    if (!widget.puedeEditar) return;
    if (fotografia.id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorCrema,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Eliminar fotografía',
            style: TextStyle(color: colorTexto, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '¿Deseas eliminar esta fotografía del lote?',
            style: TextStyle(color: Colors.black87, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: colorTierra),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorBarro,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) return;

    try {
      await _repository.eliminar(fotografia.id!);

      if (!mounted) return;

      await _cargarFotografias();

      if (!mounted) return;

      _mostrarMensaje('Fotografía eliminada correctamente.');
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje('No se pudo eliminar la fotografía: $e');
    }
  }

  void _abrirFotografia(Fotografia fotografia, int indice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FotografiaVistaPage(
          fotografias: _fotografias,
          indiceInicial: indice,
          codigoLote: widget.codigoLote,
        ),
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorTierra,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorCrema,
      appBar: AppBar(
        backgroundColor: colorCrema,
        foregroundColor: colorTexto,
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RAÍZMIXTECA',
              style: TextStyle(
                color: colorVerde,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Evidencias ${widget.codigoLote}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: colorTexto,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.puedeEditar
          ? FloatingActionButton.extended(
              onPressed: _procesando ? null : _seleccionarFuente,
              backgroundColor: colorTierra,
              foregroundColor: Colors.white,
              elevation: 5,
              icon: _procesando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_a_photo_outlined),
              label: Text(
                _procesando ? 'Procesando...' : 'Agregar foto',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: colorTierra))
          : _fotografias.isEmpty
          ? _sinFotografias()
          : _mostrarFotografias(),
    );
  }

  Widget _sinFotografias() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      children: [
        _encabezado(),

        const SizedBox(height: 35),

        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: colorTierra.withOpacity(0.07)),
          ),
          child: Column(
            children: [
              Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  color: colorTierra.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  size: 50,
                  color: colorTierra,
                ),
              ),

              const SizedBox(height: 23),

              Text(
                widget.puedeEditar
                    ? 'Aún no hay evidencias'
                    : 'No hay evidencias disponibles',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: colorTexto,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.puedeEditar
                    ? 'Agrega fotografías para documentar '
                          'visualmente el proceso de producción '
                          'de este lote.'
                    : 'Este lote todavía no cuenta con '
                          'fotografías de evidencia.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              if (widget.puedeEditar) ...[
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _procesando ? null : _seleccionarFuente,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorTierra,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text(
                      'AGREGAR FOTOGRAFÍA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [colorTierra, colorBarro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colorTierra.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.photo_camera_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EVIDENCIAS DEL LOTE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_fotografias.length} '
                  '${_fotografias.length == 1 ? 'fotografía' : 'fotografías'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mostrarFotografias() {
    return RefreshIndicator(
      color: colorTierra,
      onRefresh: _cargarFotografias,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemCount: _fotografias.length,
        itemBuilder: (context, index) {
          final fotografia = _fotografias[index];

          return _tarjetaFotografia(fotografia, index);
        },
      ),
    );
  }

  Widget _tarjetaFotografia(Fotografia fotografia, int indice) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          _abrirFotografia(fotografia, indice);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 13,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _imagen(fotografia),

                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),

                    if (widget.puedeEditar)
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Material(
                          color: Colors.black.withOpacity(0.48),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              _eliminarFotografia(fotografia);
                            },
                            child: const SizedBox(
                              width: 38,
                              height: 38,
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorVerde.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.photo_outlined,
                        color: colorVerde,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Ver fotografía',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorTexto,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: colorTierra,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagen(Fotografia fotografia) {
    final archivo = File(fotografia.ruta);

    return Image.file(
      archivo,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: colorTierra.withOpacity(0.07),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 45,
                    color: colorTierra,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No se pudo cargar\nla imagen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorTexto,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// VISUALIZADOR DE FOTOGRAFÍA
// ============================================================

class FotografiaVistaPage extends StatefulWidget {
  final List<Fotografia> fotografias;
  final int indiceInicial;
  final String codigoLote;

  const FotografiaVistaPage({
    super.key,
    required this.fotografias,
    required this.indiceInicial,
    required this.codigoLote,
  });

  @override
  State<FotografiaVistaPage> createState() => _FotografiaVistaPageState();
}

class _FotografiaVistaPageState extends State<FotografiaVistaPage> {
  late final PageController _pageController;
  late int _indiceActual;

  @override
  void initState() {
    super.initState();

    _indiceActual = widget.indiceInicial;

    _pageController = PageController(initialPage: widget.indiceInicial);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Foto ${_indiceActual + 1} de '
          '${widget.fotografias.length}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.fotografias.length,
        onPageChanged: (index) {
          setState(() {
            _indiceActual = index;
          });
        },
        itemBuilder: (context, index) {
          final fotografia = widget.fotografias[index];

          final archivo = File(fotografia.ruta);

          return Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.file(
                archivo,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                        size: 70,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'No se pudo cargar la imagen.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.fotografias.length > 1
          ? SafeArea(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Desliza para ver más fotografías',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
