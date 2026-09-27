import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../models/productor.dart';
import '../repositories/producto_repository.dart';
import '../repositories/productor_repository.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final _productoRepository = ProductoRepository();
  final _productorRepository = ProductorRepository();

  List<Producto> _productos = [];
  Map<int, Productor> _productores = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final productos = await _productoRepository.obtenerTodos();
    final productores = await _productorRepository.obtenerTodos();

    if (!mounted) return;

    setState(() {
      _productos = productos;
      _productores = {
        for (final productor in productores)
          if (productor.id != null) productor.id!: productor,
      };
      _cargando = false;
    });
  }

  Future<void> _mostrarFormulario() async {
    if (_productores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debes registrar al menos un productor.'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductoFormPage(productores: _productores.values.toList()),
      ),
    );

    await _cargarDatos();
  }

  Future<void> _eliminarProducto(Producto producto) async {
    if (producto.id == null) return;

    await _productoRepository.eliminar(producto.id!);
    await _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormulario,
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _productos.isEmpty
          ? const Center(
              child: Text(
                'No hay productos registrados.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _productos.length,
              itemBuilder: (context, index) {
                final producto = _productos[index];

                final productor = _productores[producto.productorId];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
                    title: Text(producto.nombre),
                    subtitle: Text(
                      'Tipo: ${producto.tipo}\n'
                      'Productor: ${productor?.nombre ?? 'Desconocido'}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _eliminarProducto(producto);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ProductoFormPage extends StatefulWidget {
  final List<Productor> productores;

  const ProductoFormPage({super.key, required this.productores});

  @override
  State<ProductoFormPage> createState() => _ProductoFormPageState();
}

class _ProductoFormPageState extends State<ProductoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ProductoRepository();

  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  int? _productorSeleccionado;
  String? _tipoSeleccionado;

  final List<String> _tipos = [
    'Alimento',
    'Bebida',
    'Artesanía',
    'Textil',
    'Agrícola',
    'Otro',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final producto = Producto(
      productorId: _productorSeleccionado!,
      nombre: _nombreController.text.trim(),
      tipo: _tipoSeleccionado!,
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
    );

    await _repository.insertar(producto);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar producto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el nombre del producto';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _tipoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de producto',
                border: OutlineInputBorder(),
              ),
              items: _tipos.map((tipo) {
                return DropdownMenuItem(value: tipo, child: Text(tipo));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoSeleccionado = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecciona un tipo';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              initialValue: _productorSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Productor',
                border: OutlineInputBorder(),
              ),
              items: widget.productores.map((productor) {
                return DropdownMenuItem(
                  value: productor.id,
                  child: Text('${productor.nombre} ${productor.apellidos}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _productorSeleccionado = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecciona un productor';
                }

                return null;
              },
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
                label: const Text('GUARDAR PRODUCTO'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
