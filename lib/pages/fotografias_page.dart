import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/fotografia.dart';
import '../repositories/fotografia_repository.dart';

class FotografiasPage extends StatefulWidget {
  final int loteId;
  final String codigoLote;

  const FotografiasPage({
    super.key,
    required this.loteId,
    required this.codigoLote,
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

  @override
  void initState() {
    super.initState();
    _cargarFotografias();
  }

  Future<void> _cargarFotografias() async {
    final fotografias = await _repository.obtenerPorLote(widget.loteId);

    if (!mounted) return;

    setState(() {
      _fotografias = fotografias;
      _cargando = false;
    });
  }

  Future<void> _seleccionarFuente() async {
    final fuente = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar fotografía'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || fuente == null) return;

    await _agregarFotografia(fuente);
  }

  Future<void> _agregarFotografia(ImageSource fuente) async {
    if (_procesando) return;

    setState(() {
      _procesando = true;
    });

    try {
      final imagen = await _picker.pickImage(source: fuente, imageQuality: 85);

      if (imagen == null) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotografía agregada correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo agregar la fotografía: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _procesando = false;
        });
      }
    }
  }

  Future<void> _eliminarFotografia(Fotografia fotografia) async {
    if (fotografia.id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar fotografía'),
          content: const Text('¿Deseas eliminar esta fotografía del lote?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Eliminar'),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotografía eliminada correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la fotografía: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fotografías ${widget.codigoLote}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _procesando ? null : _seleccionarFuente,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Agregar'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _fotografias.isEmpty
          ? _sinFotografias()
          : _mostrarFotografias(),
    );
  }

  Widget _sinFotografias() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined, size: 90),
            const SizedBox(height: 20),
            const Text(
              'No hay fotografías registradas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Agrega fotografías como evidencia '
              'del proceso de producción.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _seleccionarFuente,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('AGREGAR FOTOGRAFÍA'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mostrarFotografias() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _fotografias.length,
      itemBuilder: (context, index) {
        final fotografia = _fotografias[index];

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _imagen(fotografia)),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Evidencia del lote',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _eliminarFotografia(fotografia);
                      },
                      icon: const Icon(Icons.delete),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _imagen(Fotografia fotografia) {
    final archivo = File(fotografia.ruta);

    return Image.file(
      archivo,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 50),
                SizedBox(height: 8),
                Text(
                  'No se pudo cargar la imagen.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
