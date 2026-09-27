import 'package:flutter/material.dart';

import '../models/lote.dart';
import '../models/producto.dart';
import '../models/productor.dart';
import '../repositories/lote_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/productor_repository.dart';
import 'fotografias_page.dart';
import 'proceso_page.dart';

class LotesPage extends StatefulWidget {
  const LotesPage({super.key});

  @override
  State<LotesPage> createState() => _LotesPageState();
}

class _LotesPageState extends State<LotesPage> {
  final _loteRepository = LoteRepository();
  final _productoRepository = ProductoRepository();
  final _productorRepository = ProductorRepository();

  List<Lote> _lotes = [];
  Map<int, Producto> _productos = {};
  Map<int, Productor> _productores = {};

  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final lotes = await _loteRepository.obtenerTodos();
    final productos = await _productoRepository.obtenerTodos();
    final productores = await _productorRepository.obtenerTodos();

    if (!mounted) return;

    setState(() {
      _lotes = lotes;

      _productos = {
        for (final producto in productos)
          if (producto.id != null) producto.id!: producto,
      };

      _productores = {
        for (final productor in productores)
          if (productor.id != null) productor.id!: productor,
      };

      _cargando = false;
    });
  }

  Future<void> _mostrarFormulario() async {
    if (_productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debes registrar al menos un producto.'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoteFormPage(productos: _productos.values.toList()),
      ),
    );

    if (!mounted) return;

    await _cargarDatos();
  }

  Future<void> _eliminarLote(Lote lote) async {
    if (lote.id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar lote'),
          content: Text(
            '¿Deseas eliminar el lote ${lote.codigoLote}? '
            'También se eliminarán su proceso y fotografías.',
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

    if (!mounted || confirmar != true) return;

    await _loteRepository.eliminar(lote.id!);

    if (!mounted) return;

    await _cargarDatos();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lote eliminado correctamente.')),
    );
  }

  void _abrirDetalle(Lote lote) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoteDetallePage(
          lote: lote,
          producto: _productos[lote.productoId],
          productor: _obtenerProductorDelProducto(lote.productoId),
        ),
      ),
    );
  }

  Productor? _obtenerProductorDelProducto(int productoId) {
    final producto = _productos[productoId];

    if (producto == null) {
      return null;
    }

    return _productores[producto.productorId];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lotes y trazabilidad')),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormulario,
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _lotes.isEmpty
          ? const Center(
              child: Text(
                'No hay lotes registrados.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _lotes.length,
              itemBuilder: (context, index) {
                final lote = _lotes[index];

                final producto = _productos[lote.productoId];

                final productor = _obtenerProductorDelProducto(lote.productoId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.qr_code_2)),
                    title: Text(
                      lote.codigoLote,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Producto: '
                      '${producto?.nombre ?? 'Desconocido'}\n'
                      'Productor: '
                      '${productor?.nombre ?? 'Desconocido'} '
                      '${productor?.apellidos ?? ''}\n'
                      'Producción: '
                      '${lote.fechaProduccion}',
                    ),
                    isThreeLine: true,
                    onTap: () {
                      _abrirDetalle(lote);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _eliminarLote(lote);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class LoteFormPage extends StatefulWidget {
  final List<Producto> productos;

  const LoteFormPage({super.key, required this.productos});

  @override
  State<LoteFormPage> createState() => _LoteFormPageState();
}

class _LoteFormPageState extends State<LoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = LoteRepository();

  final _codigoController = TextEditingController();
  final _descripcionController = TextEditingController();

  int? _productoSeleccionado;
  DateTime? _fechaProduccion;

  @override
  void dispose() {
    _codigoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Selecciona la fecha de producción',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (!mounted || fecha == null) return;

    setState(() {
      _fechaProduccion = fecha;
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaProduccion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha de producción.')),
      );
      return;
    }

    final fecha = _fechaProduccion!;

    final lote = Lote(
      productoId: _productoSeleccionado!,
      codigoLote: _codigoController.text.trim(),
      fechaProduccion:
          '${fecha.year.toString().padLeft(4, '0')}-'
          '${fecha.month.toString().padLeft(2, '0')}-'
          '${fecha.day.toString().padLeft(2, '0')}',
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
    );

    try {
      await _repository.insertar(lote);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo guardar el lote: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar lote')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _codigoController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Código de lote',
                hintText: 'Ejemplo: RM-001',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el código del lote';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              initialValue: _productoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Producto',
                border: OutlineInputBorder(),
              ),
              items: widget.productos.map((producto) {
                return DropdownMenuItem<int>(
                  value: producto.id,
                  child: Text(producto.nombre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _productoSeleccionado = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecciona un producto';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: _seleccionarFecha,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de producción',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                child: Text(
                  _fechaProduccion == null
                      ? 'Seleccionar fecha'
                      : '${_fechaProduccion!.day.toString().padLeft(2, '0')}/'
                            '${_fechaProduccion!.month.toString().padLeft(2, '0')}/'
                            '${_fechaProduccion!.year}',
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR LOTE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoteDetallePage extends StatelessWidget {
  final Lote lote;
  final Producto? producto;
  final Productor? productor;

  const LoteDetallePage({
    super.key,
    required this.lote,
    required this.producto,
    required this.productor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lote ${lote.codigoLote}')),
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
                    'INFORMACIÓN DEL LOTE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  _dato('Código de lote', lote.codigoLote),

                  _dato('Producto', producto?.nombre ?? 'Desconocido'),

                  _dato('Tipo', producto?.tipo ?? 'Desconocido'),

                  _dato(
                    'Productor',
                    productor == null
                        ? 'Desconocido'
                        : '${productor!.nombre} '
                              '${productor!.apellidos}',
                  ),

                  _dato('Comunidad', productor?.comunidad ?? 'Desconocida'),

                  _dato('Municipio', productor?.municipio ?? 'Desconocido'),

                  _dato('Fecha de producción', lote.fechaProduccion),

                  if (lote.descripcion != null && lote.descripcion!.isNotEmpty)
                    _dato('Descripción', lote.descripcion!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.account_tree)),
              title: const Text(
                'Proceso de producción',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Registrar las etapas del proceso.'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (lote.id == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProcesoPage(
                      loteId: lote.id!,
                      codigoLote: lote.codigoLote,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.photo_library)),
              title: const Text(
                'Fotografías',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Agregar evidencias fotográficas del lote.'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (lote.id == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FotografiasPage(
                      loteId: lote.id!,
                      codigoLote: lote.codigoLote,
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

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(valor),
        ],
      ),
    );
  }
}
