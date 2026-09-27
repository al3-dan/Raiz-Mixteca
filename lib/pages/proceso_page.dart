import 'package:flutter/material.dart';

import '../models/proceso.dart';
import '../repositories/proceso_repository.dart';

class ProcesoPage extends StatefulWidget {
  final int loteId;
  final String codigoLote;

  const ProcesoPage({
    super.key,
    required this.loteId,
    required this.codigoLote,
  });

  @override
  State<ProcesoPage> createState() => _ProcesoPageState();
}

class _ProcesoPageState extends State<ProcesoPage> {
  final _repository = ProcesoRepository();

  Proceso? _proceso;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProceso();
  }

  Future<void> _cargarProceso() async {
    final proceso = await _repository.obtenerPorLote(widget.loteId);

    if (!mounted) return;

    setState(() {
      _proceso = proceso;
      _cargando = false;
    });
  }

  Future<void> _mostrarFormulario() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProcesoFormPage(loteId: widget.loteId, proceso: _proceso),
      ),
    );

    if (!mounted) return;

    await _cargarProceso();
  }

  Future<void> _eliminarProceso() async {
    if (_proceso?.id == null) return;

    await _repository.eliminar(_proceso!.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proceso eliminado correctamente.')),
    );

    await _cargarProceso();
  }

  Future<void> _confirmarEliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar proceso'),
          content: const Text(
            '¿Deseas eliminar el proceso registrado para este lote?',
          ),
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

    if (!mounted) return;

    if (confirmar == true) {
      await _eliminarProceso();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Proceso ${widget.codigoLote}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarFormulario,
        icon: Icon(_proceso == null ? Icons.add : Icons.edit),
        label: Text(_proceso == null ? 'Registrar' : 'Editar'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _proceso == null
          ? _sinProceso()
          : _mostrarProceso(),
    );
  }

  Widget _sinProceso() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_tree, size: 80),
            const SizedBox(height: 20),
            const Text(
              'No hay proceso registrado.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Registra las etapas de producción de este lote.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _mostrarFormulario,
              icon: const Icon(Icons.add),
              label: const Text('REGISTRAR PROCESO'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mostrarProceso() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PROCESO DE PRODUCCIÓN',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _dato('Descripción', _proceso!.descripcion),
                const SizedBox(height: 15),
                _dato('Etapas', _proceso!.etapas),
                const SizedBox(height: 15),
                _dato('Observaciones', _proceso!.observaciones),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _confirmarEliminar,
          icon: const Icon(Icons.delete),
          label: const Text('ELIMINAR PROCESO'),
        ),
      ],
    );
  }

  Widget _dato(String titulo, String? valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(valor == null || valor.isEmpty ? 'Sin información' : valor),
      ],
    );
  }
}

class ProcesoFormPage extends StatefulWidget {
  final int loteId;
  final Proceso? proceso;

  const ProcesoFormPage({super.key, required this.loteId, this.proceso});

  @override
  State<ProcesoFormPage> createState() => _ProcesoFormPageState();
}

class _ProcesoFormPageState extends State<ProcesoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ProcesoRepository();

  final _descripcionController = TextEditingController();
  final _etapasController = TextEditingController();
  final _observacionesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final proceso = widget.proceso;

    if (proceso != null) {
      _descripcionController.text = proceso.descripcion ?? '';

      _etapasController.text = proceso.etapas ?? '';

      _observacionesController.text = proceso.observaciones ?? '';
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _etapasController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final proceso = Proceso(
      id: widget.proceso?.id,
      loteId: widget.loteId,
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
      etapas: _etapasController.text.trim().isEmpty
          ? null
          : _etapasController.text.trim(),
      observaciones: _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim(),
    );

    try {
      if (widget.proceso == null) {
        await _repository.insertar(proceso);
      } else {
        await _repository.actualizar(proceso);
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el proceso: $e')),
      );
    }
  }

  Widget _campo(
    String etiqueta,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: etiqueta,
          hintText: hint,
          border: const OutlineInputBorder(),
          alignLabelWithHint: maxLines > 1,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Este campo es obligatorio';
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.proceso != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar proceso' : 'Registrar proceso'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _campo(
              'Descripción',
              _descripcionController,
              hint: 'Describe brevemente el proceso.',
              maxLines: 4,
            ),
            _campo(
              'Etapas',
              _etapasController,
              hint:
                  'Ejemplo: cosecha, selección, '
                  'transformación, empaque.',
              maxLines: 6,
            ),
            _campo(
              'Observaciones',
              _observacionesController,
              hint: 'Agrega observaciones importantes.',
              maxLines: 4,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: Text(
                  editando ? 'ACTUALIZAR PROCESO' : 'GUARDAR PROCESO',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
