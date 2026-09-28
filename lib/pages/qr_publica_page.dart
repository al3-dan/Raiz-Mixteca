import 'dart:io';

import 'package:flutter/material.dart';

import '../models/fotografia.dart';
import '../models/lote.dart';
import '../models/producto.dart';
import '../models/productor.dart';
import '../models/proceso.dart';
import '../repositories/fotografia_repository.dart';
import '../repositories/lote_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/productor_repository.dart';
import '../repositories/proceso_repository.dart';

class QrPublicaPage extends StatefulWidget {
  final String codigoLote;

  const QrPublicaPage({super.key, required this.codigoLote});

  @override
  State<QrPublicaPage> createState() => _QrPublicaPageState();
}

class _QrPublicaPageState extends State<QrPublicaPage> {
  final _loteRepository = LoteRepository();
  final _productoRepository = ProductoRepository();
  final _productorRepository = ProductorRepository();
  final _fotografiaRepository = FotografiaRepository();
  final _procesoRepository = ProcesoRepository();

  Lote? _lote;
  Producto? _producto;
  Productor? _productor;
  Proceso? _proceso;
  List<Fotografia> _fotografias = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarInformacion();
  }

  Future<void> _cargarInformacion() async {
    try {
      final lote = await _loteRepository.obtenerPorCodigo(widget.codigoLote);

      if (lote == null) {
        setState(() {
          _error = 'No se encontró el lote escaneado.';
          _cargando = false;
        });
        return;
      }

      final producto = await _productoRepository.obtenerPorId(lote.productoId);
      if (producto == null) {
        setState(() {
          _error = 'El lote no tiene un producto asociado.';
          _cargando = false;
        });
        return;
      }

      final productor = await _productorRepository.obtenerPorId(
        producto.productorId,
      );
      final fotografias = await _fotografiaRepository.obtenerPorLote(lote.id!);
      final proceso = await _procesoRepository.obtenerPorLote(lote.id!);

      setState(() {
        _lote = lote;
        _producto = producto;
        _productor = productor;
        _proceso = proceso;
        _fotografias = fotografias;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo consultar la información del lote: $e';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _lote == null || _producto == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Consulta pública')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error ?? 'El lote escaneado no está disponible.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    final mostrarNombre = _productor?.mostrarNombre == 1;
    final mostrarComunidad = _productor?.mostrarComunidad == 1;
    final mostrarContacto = _productor?.mostrarContacto == 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Consulta pública')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRODUCTO',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _producto!.nombre,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _fila(
                    'Productor',
                    mostrarNombre
                        ? '${_productor!.nombre} ${_productor!.apellidos}'
                        : 'No disponible',
                  ),
                  _fila(
                    'Comunidad',
                    mostrarComunidad ? _productor!.comunidad : 'No disponible',
                  ),
                  _fila('Lote', _lote!.codigoLote),
                  _fila('Producción', _lote!.fechaProduccion),
                  _fila('Tipo', _producto!.tipo),
                  if (_lote!.descripcion != null &&
                      _lote!.descripcion!.isNotEmpty)
                    _fila('Descripción', _lote!.descripcion!),
                  if (_producto!.descripcion != null &&
                      _producto!.descripcion!.isNotEmpty)
                    _fila('Detalles del producto', _producto!.descripcion!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROCESO DE PRODUCCIÓN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _fila(
                    'Descripción',
                    _proceso?.descripcion ?? 'Sin información',
                  ),
                  _fila('Etapas', _proceso?.etapas ?? 'Sin información'),
                  _fila(
                    'Observaciones',
                    _proceso?.observaciones ?? 'Sin información',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FOTOGRAFÍAS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_fotografias.isEmpty)
                    const Text('No hay fotografías registradas para este lote.')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _fotografias.map((foto) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            toFile(foto.ruta),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONTACTO',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (mostrarContacto)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_productor!.correo != null &&
                            _productor!.correo!.isNotEmpty)
                          _fila('Correo', _productor!.correo!),
                        if (_productor!.telefono != null &&
                            _productor!.telefono!.isNotEmpty)
                          _fila('Teléfono', _productor!.telefono!),
                      ],
                    )
                  else
                    const Text(
                      'El productor no ha habilitado contacto público para este lote.',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$etiqueta:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 3, child: Text(valor)),
        ],
      ),
    );
  }

  File toFile(String path) => File(path);
}
