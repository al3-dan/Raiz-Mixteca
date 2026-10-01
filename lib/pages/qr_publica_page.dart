import 'dart:io';

import 'package:flutter/material.dart';

import '../models/fotografia.dart';
import '../models/lote.dart';
import '../models/proceso.dart';
import '../models/producto.dart';
import '../models/productor.dart';
import '../repositories/fotografia_repository.dart';
import '../repositories/lote_repository.dart';
import '../repositories/proceso_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/productor_repository.dart';

class QrPublicaPage extends StatefulWidget {
  final String codigoLote;

  const QrPublicaPage({super.key, required this.codigoLote});

  @override
  State<QrPublicaPage> createState() => _QrPublicaPageState();
}

class _QrPublicaPageState extends State<QrPublicaPage> {
  static const Color colorTerracota = Color(0xFFB85C38);
  static const Color colorCrema = Color(0xFFF5F0E7);
  static const Color colorCafe = Color(0xFF211B17);
  static const Color colorVerde = Color(0xFF50634A);
  static const Color colorDorado = Color(0xFFD99A32);

  final LoteRepository _loteRepository = LoteRepository();
  final ProductoRepository _productoRepository = ProductoRepository();
  final ProductorRepository _productorRepository = ProductorRepository();
  final ProcesoRepository _procesoRepository = ProcesoRepository();
  final FotografiaRepository _fotografiaRepository = FotografiaRepository();

  Lote? _lote;
  Producto? _producto;
  Productor? _productor;
  Proceso? _proceso;

  // IMPORTANTE:
  // La lista se llama _listaFotografias para no chocar
  // con el método _fotografias().
  List<Fotografia> _listaFotografias = [];

  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarInformacion();
  }

  Future<void> _cargarInformacion() async {
    try {
      setState(() {
        _cargando = true;
        _error = null;
      });

      final lote = await _loteRepository.obtenerPorCodigo(widget.codigoLote);

      if (lote == null) {
        setState(() {
          _cargando = false;
          _error = 'No se encontró información para este código QR.';
        });
        return;
      }

      final producto = await _productoRepository.obtenerPorId(lote.productoId);

      if (producto == null) {
        setState(() {
          _cargando = false;
          _error = 'No se encontró el producto relacionado con este lote.';
        });
        return;
      }

      final productor = await _productorRepository.obtenerPorId(
        producto.productorId,
      );

      Proceso? proceso;

      if (lote.id != null) {
        proceso = await _procesoRepository.obtenerPorLote(lote.id!);

        // AQUÍ está la corrección principal.
        _listaFotografias = await _fotografiaRepository.obtenerPorLote(
          lote.id!,
        );
      }

      if (!mounted) return;

      setState(() {
        _lote = lote;
        _producto = producto;
        _productor = productor;
        _proceso = proceso;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = 'No fue posible cargar la información del producto.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorCrema,
      body: _cargando
          ? _pantallaCarga()
          : _error != null
          ? _pantallaError()
          : _contenido(),
    );
  }

  Widget _pantallaCarga() {
    return const Center(
      child: CircularProgressIndicator(color: colorTerracota),
    );
  }

  Widget _pantallaError() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: colorTerracota.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 46,
                  color: colorTerracota,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Información no encontrada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colorCafe,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _error ?? 'Ocurrió un problema.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: colorCafe.withOpacity(.65),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Regresar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorTerracota,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contenido() {
    return CustomScrollView(
      slivers: [
        _appBar(),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroProducto(),
                const SizedBox(height: 20),
                _identidadProductor(),
                const SizedBox(height: 18),
                _informacionLote(),
                const SizedBox(height: 18),
                _trazabilidad(),
                const SizedBox(height: 18),
                _fotografias(),
                const SizedBox(height: 18),
                _contactoProductor(),
                const SizedBox(height: 28),
                _footer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _appBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: colorCrema,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded, color: colorCafe),
      ),
      title: const Text(
        'RaízMixteca',
        style: TextStyle(
          color: colorCafe,
          fontWeight: FontWeight.w900,
          fontSize: 21,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: colorVerde.withOpacity(.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_rounded, size: 17, color: colorVerde),
              SizedBox(width: 5),
              Text(
                'Verificado',
                style: TextStyle(
                  color: colorVerde,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _heroProducto() {
    final fotos = _listaFotografias;

    return Container(
      width: double.infinity,
      height: 360,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: colorCafe,
        boxShadow: [
          BoxShadow(
            color: colorCafe.withOpacity(.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (fotos.isNotEmpty)
            Image.file(
              File(fotos.first.ruta),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _placeholderHero();
              },
            )
          else
            _placeholderHero(),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(.08),
                    Colors.black.withOpacity(.78),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_producto != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colorDorado,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _producto!.tipo.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  _producto?.nombre ?? 'Producto RaízMixteca',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Lote ${_lote?.codigoLote ?? widget.codigoLote}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.88),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorTerracota, colorDorado, colorCafe],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -30,
            child: Icon(
              Icons.eco_rounded,
              size: 180,
              color: Colors.white.withOpacity(.10),
            ),
          ),
          Positioned(
            left: 28,
            top: 35,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 45,
              color: Colors.white.withOpacity(.16),
            ),
          ),
          const Center(
            child: Icon(Icons.eco_rounded, size: 90, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _identidadProductor() {
    if (_productor == null) {
      return const SizedBox.shrink();
    }

    final productor = _productor!;

    final nombreCompleto = '${productor.nombre} ${productor.apellidos}'.trim();

    final mostrarNombre = productor.mostrarNombre == 1;
    final mostrarComunidad = productor.mostrarComunidad == 1;

    return _card(
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colorVerde.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: colorVerde,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRODUCTOR',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                    color: colorVerde,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mostrarNombre ? nombreCompleto : 'Productor de la región',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: colorCafe,
                  ),
                ),
                if (mostrarComunidad) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: colorTerracota,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${productor.comunidad}, ${productor.municipio}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorCafe.withOpacity(.65),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _informacionLote() {
    final lote = _lote;

    if (lote == null) {
      return const SizedBox.shrink();
    }

    return _sectionCard(
      icon: Icons.inventory_2_outlined,
      title: 'Información del lote',
      child: Column(
        children: [
          _dato(Icons.qr_code_2_rounded, 'Código de lote', lote.codigoLote),
          const SizedBox(height: 14),
          _dato(
            Icons.calendar_month_outlined,
            'Fecha de producción',
            lote.fechaProduccion,
          ),
          if ((_producto?.tipo ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            _dato(Icons.category_outlined, 'Tipo de producto', _producto!.tipo),
          ],
          if ((lote.descripcion ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                lote.descripcion!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: colorCafe.withOpacity(.72),
                ),
              ),
            ),
          ],
          if ((_producto?.descripcion ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: colorDorado.withOpacity(.09),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: colorDorado,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _producto!.descripcion!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: colorCafe.withOpacity(.72),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _trazabilidad() {
    final proceso = _proceso;

    if (proceso == null) {
      return _sectionCard(
        icon: Icons.route_outlined,
        title: 'Trazabilidad',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorCrema,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: colorDorado),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Todavía no hay etapas de proceso registradas para este lote.',
                  style: TextStyle(
                    color: colorCafe.withOpacity(.68),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final etapas = _obtenerEtapas(proceso.etapas);

    return _sectionCard(
      icon: Icons.route_outlined,
      title: 'Trazabilidad',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((proceso.descripcion ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                proceso.descripcion!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: colorCafe.withOpacity(.70),
                ),
              ),
            ),
          if (etapas.isNotEmpty)
            _timeline(etapas)
          else
            Text(
              'Proceso registrado sin etapas detalladas.',
              style: TextStyle(color: colorCafe.withOpacity(.65)),
            ),
          if ((proceso.observaciones ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: colorVerde.withOpacity(.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, color: colorVerde),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      proceso.observaciones!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: colorCafe.withOpacity(.72),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _obtenerEtapas(String? etapas) {
    if (etapas == null || etapas.trim().isEmpty) {
      return [];
    }

    return etapas
        .split(RegExp(r'[,;\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Widget _timeline(List<String> etapas) {
    return Column(
      children: List.generate(etapas.length, (index) {
        final ultima = index == etapas.length - 1;

        return _timelineItem(
          numero: index + 1,
          texto: etapas[index],
          ultima: ultima,
        );
      }),
    );
  }

  Widget _timelineItem({
    required int numero,
    required String texto,
    required bool ultima,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorVerde,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorVerde.withOpacity(.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$numero',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                if (!ultima)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: colorVerde.withOpacity(.22),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: ultima ? 0 : 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorCrema,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco_outlined, color: colorVerde, size: 19),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      texto,
                      style: const TextStyle(
                        color: colorCafe,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ESTE ES EL MÉTODO QUE ANTES CHOCABA CON LA LISTA.
  // Ahora la lista se llama _listaFotografias.
  Widget _fotografias() {
    if (_listaFotografias.isEmpty) {
      return _sectionCard(
        icon: Icons.photo_library_outlined,
        title: 'Evidencia fotográfica',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorCrema,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.photo_camera_back_outlined,
                size: 38,
                color: colorTerracota,
              ),
              const SizedBox(height: 10),
              Text(
                'Este lote todavía no cuenta con fotografías.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorCafe.withOpacity(.68),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _sectionCard(
      icon: Icons.photo_library_outlined,
      title: 'Evidencia fotográfica',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_listaFotografias.length} '
            '${_listaFotografias.length == 1 ? 'fotografía' : 'fotografías'} '
            'registradas',
            style: TextStyle(color: colorCafe.withOpacity(.62), fontSize: 13),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 175,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _listaFotografias.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final foto = _listaFotografias[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _FotoPublicaPage(
                          fotografias: _listaFotografias,
                          indiceInicial: index,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 220,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: colorCafe,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(foto.ruta),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: colorCafe,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white54,
                                  size: 42,
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.55),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              foto.descripcion?.trim().isNotEmpty == true
                                  ? foto.descripcion!
                                  : 'Evidencia ${index + 1}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactoProductor() {
    final productor = _productor;

    if (productor == null || productor.mostrarContacto != 1) {
      return const SizedBox.shrink();
    }

    final tieneTelefono =
        productor.telefono != null && productor.telefono!.trim().isNotEmpty;

    final tieneCorreo =
        productor.correo != null && productor.correo!.trim().isNotEmpty;

    if (!tieneTelefono && !tieneCorreo) {
      return const SizedBox.shrink();
    }

    return _sectionCard(
      icon: Icons.handshake_outlined,
      title: 'Contacto',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'El productor ha decidido compartir sus datos de contacto.',
            style: TextStyle(
              color: colorCafe.withOpacity(.68),
              height: 1.45,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 15),
          if (tieneTelefono)
            _contactoItem(
              Icons.phone_outlined,
              'Teléfono',
              productor.telefono!,
            ),
          if (tieneTelefono && tieneCorreo) const SizedBox(height: 10),
          if (tieneCorreo)
            _contactoItem(Icons.email_outlined, 'Correo', productor.correo!),
        ],
      ),
    );
  }

  Widget _contactoItem(IconData icono, String titulo, String valor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colorCrema,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorTerracota.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: colorTerracota, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorCafe.withOpacity(.55),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 14,
                    color: colorCafe,
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

  Widget _dato(IconData icono, String titulo, String valor) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorTerracota.withOpacity(.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icono, color: colorTerracota, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 11,
                  color: colorCafe.withOpacity(.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 14,
                  color: colorCafe,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorTerracota.withOpacity(.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: colorTerracota, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: colorCafe,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorCafe.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _footer() {
    return Column(
      children: [
        Container(
          width: 55,
          height: 4,
          decoration: BoxDecoration(
            color: colorDorado,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'RaízMixteca',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: colorCafe,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Del origen a tus manos.',
          style: TextStyle(
            color: colorCafe.withOpacity(.55),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Trazabilidad • Cultura • Comunidad',
          style: TextStyle(
            color: colorVerde.withOpacity(.75),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
      ],
    );
  }
}

class _FotoPublicaPage extends StatefulWidget {
  final List<Fotografia> fotografias;
  final int indiceInicial;

  const _FotoPublicaPage({
    required this.fotografias,
    required this.indiceInicial,
  });

  @override
  State<_FotoPublicaPage> createState() => _FotoPublicaPageState();
}

class _FotoPublicaPageState extends State<_FotoPublicaPage> {
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
        title: Text(
          'Foto ${_indiceActual + 1} de ${widget.fotografias.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
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
          final foto = widget.fotografias[index];

          return InteractiveViewer(
            minScale: .8,
            maxScale: 4,
            child: Center(
              child: Image.file(
                File(foto.ruta),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 60,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No se pudo cargar esta fotografía.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar:
          widget.fotografias[_indiceActual].descripcion?.trim().isNotEmpty ==
              true
          ? SafeArea(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                child: Text(
                  widget.fotografias[_indiceActual].descripcion!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
