import 'package:flutter/material.dart';

import '../models/productor.dart';
import '../repositories/productor_repository.dart';

class ProductoresPage extends StatefulWidget {
  const ProductoresPage({super.key});

  @override
  State<ProductoresPage> createState() => _ProductoresPageState();
}

class _ProductoresPageState extends State<ProductoresPage> {
  final ProductorRepository _repository = ProductorRepository();

  List<Productor> _productores = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProductores();
  }

  Future<void> _cargarProductores() async {
    final productores = await _repository.obtenerTodos();

    if (!mounted) return;

    setState(() {
      _productores = productores;
      _cargando = false;
    });
  }

  Future<void> _mostrarFormulario() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductorFormPage()),
    );

    await _cargarProductores();
  }

  Future<void> _eliminarProductor(Productor productor) async {
    if (productor.id == null) return;

    await _repository.eliminar(productor.id!);
    await _cargarProductores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productores')),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormulario,
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _productores.isEmpty
          ? const Center(
              child: Text(
                'No hay productores registrados.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _productores.length,
              itemBuilder: (context, index) {
                final productor = _productores[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text('${productor.nombre} ${productor.apellidos}'),
                    subtitle: Text(
                      '${productor.comunidad}, ${productor.municipio}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _eliminarProductor(productor);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ProductorFormPage extends StatefulWidget {
  const ProductorFormPage({super.key});

  @override
  State<ProductorFormPage> createState() => _ProductorFormPageState();
}

class _ProductorFormPageState extends State<ProductorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ProductorRepository();

  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _comunidadController = TextEditingController();
  final _municipioController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _descripcionController = TextEditingController();

  bool _mostrarNombre = true;
  bool _mostrarComunidad = true;
  bool _mostrarContacto = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _comunidadController.dispose();
    _municipioController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final productor = Productor(
      nombre: _nombreController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      comunidad: _comunidadController.text.trim(),
      municipio: _municipioController.text.trim(),
      telefono: _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim(),
      correo: _correoController.text.trim().isEmpty
          ? null
          : _correoController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
      mostrarNombre: _mostrarNombre ? 1 : 0,
      mostrarComunidad: _mostrarComunidad ? 1 : 0,
      mostrarContacto: _mostrarContacto ? 1 : 0,
      fechaRegistro: DateTime.now().toIso8601String(),
    );

    await _repository.insertar(productor);

    if (!mounted) return;

    Navigator.pop(context);
  }

  Widget _campo(
    String etiqueta,
    TextEditingController controller, {
    bool obligatorio = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
        validator: obligatorio
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }

                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar productor')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _campo('Nombre', _nombreController, obligatorio: true),
            _campo('Apellidos', _apellidosController, obligatorio: true),
            _campo('Comunidad', _comunidadController, obligatorio: true),
            _campo('Municipio', _municipioController, obligatorio: true),
            _campo('Teléfono', _telefonoController),
            _campo('Correo', _correoController),
            _campo('Descripción', _descripcionController),

            SwitchListTile(
              title: const Text('Mostrar nombre'),
              value: _mostrarNombre,
              onChanged: (value) {
                setState(() {
                  _mostrarNombre = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text('Mostrar comunidad'),
              value: _mostrarComunidad,
              onChanged: (value) {
                setState(() {
                  _mostrarComunidad = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text('Mostrar contacto'),
              value: _mostrarContacto,
              onChanged: (value) {
                setState(() {
                  _mostrarContacto = value;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _guardar,
                child: const Text('GUARDAR PRODUCTOR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
