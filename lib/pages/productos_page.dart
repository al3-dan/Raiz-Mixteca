import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../repositories/producto_repository.dart';

class ProductosPage extends StatefulWidget {
  /// Sirve para filtrar los productos que se muestran.
  ///
  /// null = mostrar todos.
  /// con ID = mostrar únicamente los productos de ese productor.
  final int? productorId;

  /// Identifica al productor que tiene la sesión iniciada.
  ///
  /// null = visitante.
  /// con ID = productor autenticado.
  final int? productorSesionId;

  const ProductosPage({super.key, this.productorId, this.productorSesionId});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final ProductoRepository _repository = ProductoRepository();

  List<Producto> _productos = [];
  bool _cargando = true;

  String _busqueda = '';
  String _filtro = 'Todos';

  static const colorTerracota = Color(0xFFB85C38);
  static const colorCrema = Color(0xFFF5F0E7);
  static const colorCafe = Color(0xFF211B17);
  static const colorVerde = Color(0xFF50634A);
  static const colorMiel = Color(0xFFD99A32);

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
    });

    try {
      final productos = widget.productorId == null
          ? await _repository.obtenerTodos()
          : await _repository.obtenerPorProductor(widget.productorId!);

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los productos: $e')),
      );
    }
  }

  List<Producto> get _productosFiltrados {
    return _productos.where((producto) {
      final texto = _busqueda.toLowerCase();

      final coincideBusqueda =
          producto.nombre.toLowerCase().contains(texto) ||
          producto.tipo.toLowerCase().contains(texto) ||
          (producto.descripcion ?? '').toLowerCase().contains(texto);

      final coincideFiltro = _filtro == 'Todos' || producto.tipo == _filtro;

      return coincideBusqueda && coincideFiltro;
    }).toList();
  }

  List<String> get _tipos {
    final tipos = _productos
        .map((producto) => producto.tipo)
        .where((tipo) => tipo.trim().isNotEmpty)
        .toSet()
        .toList();

    tipos.sort();

    return ['Todos', ...tipos];
  }

  bool _esPropietario(Producto producto) {
    return widget.productorSesionId != null &&
        producto.productorId == widget.productorSesionId;
  }

  bool get _esVisitante {
    return widget.productorSesionId == null;
  }

  bool get _puedeAgregar {
    return widget.productorSesionId != null;
  }

  Future<void> _abrirFormulario({Producto? producto}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoFormPage(
          producto: producto,
          productorId: widget.productorSesionId,
        ),
      ),
    );

    if (resultado == true && mounted) {
      await _cargarProductos();
    }
  }

  Future<void> _eliminarProducto(Producto producto) async {
    if (!_esPropietario(producto)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo puedes eliminar tus propios productos.'),
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text('¿Seguro que deseas eliminar "${producto.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: colorTerracota),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await _repository.eliminar(producto.id!);

      if (!mounted) return;

      await _cargarProductos();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el producto: $e')),
      );
    }
  }

  void _mostrarDetalle(Producto producto) {
    final esPropietario = _esPropietario(producto);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _DetalleProductoSheet(
          producto: producto,
          esPropietario: esPropietario,
          esVisitante: _esVisitante,
          onEditar: esPropietario
              ? () {
                  Navigator.pop(context);
                  _abrirFormulario(producto: producto);
                }
              : null,
          onEliminar: esPropietario
              ? () {
                  Navigator.pop(context);
                  _eliminarProducto(producto);
                }
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorCrema,
      appBar: AppBar(
        title: Text(
          widget.productorId == null
              ? 'Productos de la Mixteca'
              : 'Mis productos',
          style: const TextStyle(fontWeight: FontWeight.w800, color: colorCafe),
        ),
        backgroundColor: colorCrema,
      ),
      floatingActionButton: _puedeAgregar
          ? FloatingActionButton.extended(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
            )
          : null,
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: colorTerracota),
            )
          : RefreshIndicator(
              color: colorTerracota,
              onRefresh: _cargarProductos,
              child: _productos.isEmpty ? _estadoVacio() : _contenido(),
            ),
    );
  }

  Widget _contenido() {
    final productos = _productosFiltrados;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      children: [
        _encabezadoCatalogo(),
        const SizedBox(height: 18),
        _barraBusqueda(),
        const SizedBox(height: 14),
        _filtros(),
        const SizedBox(height: 20),
        if (productos.isEmpty)
          _sinResultados()
        else
          ...productos.map(
            (producto) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ProductoCard(
                producto: producto,
                esPropietario: _esPropietario(producto),
                onTap: () => _mostrarDetalle(producto),
              ),
            ),
          ),
      ],
    );
  }

  Widget _encabezadoCatalogo() {
    final esPropio = widget.productorId != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [colorCafe, Color(0xFF49352B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: colorMiel.withOpacity(.18),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: colorMiel,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  esPropio ? 'Mi producción' : 'Productos de la Mixteca',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  esPropio ? 'Administra los productos que has registrado.' : 'Conoce los productos registrados por nuestros productores.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.75),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraBusqueda() {
    return TextField(
      onChanged: (valor) {
        setState(() {
          _busqueda = valor;
        });
      },
      decoration: InputDecoration(
        hintText: 'Buscar producto...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _busqueda.isNotEmpty
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _busqueda = '';
                  });
                },
                icon: const Icon(Icons.close),
              )
            : null,
      ),
    );
  }

  Widget _filtros() {
    final tipos = _tipos;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tipos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final tipo = tipos[index];
          final seleccionado = _filtro == tipo;

          return ChoiceChip(
            label: Text(tipo),
            selected: seleccionado,
            onSelected: (_) {
              setState(() {
                _filtro = tipo;
              });
            },
            selectedColor: colorTerracota,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: seleccionado ? Colors.white : colorCafe,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide.none,
          );
        },
      ),
    );
  }

  Widget _sinResultados() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: colorTerracota),
          SizedBox(height: 12),
          Text(
            'No encontramos productos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colorCafe,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Prueba con otra búsqueda o categoría.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _estadoVacio() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.inventory_2_outlined,
          size: 70,
          color: colorTerracota.withOpacity(.7),
        ),
        const SizedBox(height: 20),
        Text(
          widget.productorId != null
              ? 'Todavía no tienes productos'
              : 'Todavía no hay productos registrados',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: colorCafe,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.productorId != null
              ? 'Registra tu primer producto para comenzar a construir su trazabilidad.'
              : 'Cuando los productores registren productos aparecerán aquí.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, height: 1.4),
        ),
        if (_puedeAgregar) ...[
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _abrirFormulario(),
            icon: const Icon(Icons.add),
            label: const Text('Registrar producto'),
            style: FilledButton.styleFrom(backgroundColor: colorTerracota),
          ),
        ],
      ],
    );
  }
}

class _ProductoCard extends StatelessWidget {
  final Producto producto;
  final bool esPropietario;
  final VoidCallback onTap;

  const _ProductoCard({
    required this.producto,
    required this.esPropietario,
    required this.onTap,
  });

  static const colorTerracota = Color(0xFFB85C38);
  static const colorCafe = Color(0xFF211B17);
  static const colorVerde = Color(0xFF50634A);

  @override
  Widget build(BuildContext context) {
    final descripcion = producto.descripcion?.trim() ?? '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: colorTerracota.withOpacity(.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.agriculture_outlined,
                  color: colorTerracota,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            producto.nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: colorCafe,
                            ),
                          ),
                        ),
                        if (esPropietario)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorVerde.withOpacity(.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Mío',
                              style: TextStyle(
                                color: colorVerde,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      producto.tipo,
                      style: const TextStyle(
                        color: colorTerracota,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    if (descripcion.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 9),
                    const Row(
                      children: [
                        Text(
                          'Ver información',
                          style: TextStyle(
                            color: colorCafe,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: colorTerracota,
                        ),
                      ],
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
}

class _DetalleProductoSheet extends StatelessWidget {
  final Producto producto;
  final bool esPropietario;
  final bool esVisitante;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const _DetalleProductoSheet({
    required this.producto,
    required this.esPropietario,
    required this.esVisitante,
    required this.onEditar,
    required this.onEliminar,
  });

  static const colorTerracota = Color(0xFFB85C38);
  static const colorCafe = Color(0xFF211B17);
  static const colorVerde = Color(0xFF50634A);

  @override
  Widget build(BuildContext context) {
    final descripcion = producto.descripcion?.trim() ?? '';

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 80),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F0E7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: colorTerracota.withOpacity(.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.agriculture_outlined,
                      color: colorTerracota,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          style: const TextStyle(
                            color: colorCafe,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          producto.tipo,
                          style: const TextStyle(
                            color: colorTerracota,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DatoProducto(
                icono: Icons.category_outlined,
                titulo: 'Tipo de producto',
                valor: producto.tipo,
              ),
              const SizedBox(height: 12),
              _DatoProducto(
                icono: Icons.fingerprint_outlined,
                titulo: 'Identificador del productor',
                valor: producto.productorId.toString(),
              ),
              if (descripcion.isNotEmpty) ...[
                const SizedBox(height: 12),
                _DatoProducto(
                  icono: Icons.description_outlined,
                  titulo: 'Descripción',
                  valor: descripcion,
                ),
              ],
              const SizedBox(height: 22),
              if (esPropietario) ...[
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: colorVerde.withOpacity(.09),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: colorVerde),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Este producto pertenece a tu cuenta.',
                          style: TextStyle(
                            color: colorVerde,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEditar,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorCafe,
                          side: const BorderSide(color: colorCafe),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onEliminar,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Eliminar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorTerracota,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        esVisitante
                            ? Icons.visibility_outlined
                            : Icons.lock_outline,
                        color: colorTerracota,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          esVisitante
                              ? 'Información pública del producto. Solo lectura.'
                              : 'Puedes consultar este producto, pero solo su propietario puede modificarlo.',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DatoProducto extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _DatoProducto({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  static const colorCafe = Color(0xFF211B17);
  static const colorTerracota = Color(0xFFB85C38);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: colorTerracota, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  valor,
                  style: const TextStyle(
                    color: colorCafe,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductoFormPage extends StatefulWidget {
  final Producto? producto;

  /// Productor propietario del nuevo producto.
  final int? productorId;

  const ProductoFormPage({super.key, this.producto, this.productorId});

  @override
  State<ProductoFormPage> createState() => _ProductoFormPageState();
}

class _ProductoFormPageState extends State<ProductoFormPage> {
  final ProductoRepository _repository = ProductoRepository();

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _tipoController;
  late final TextEditingController _descripcionController;

  bool _guardando = false;

  static const colorTerracota = Color(0xFFB85C38);
  static const colorCrema = Color(0xFFF5F0E7);
  static const colorCafe = Color(0xFF211B17);

  bool get _editando => widget.producto != null;

  @override
  void initState() {
    super.initState();

    _nombreController = TextEditingController(
      text: widget.producto?.nombre ?? '',
    );

    _tipoController = TextEditingController(text: widget.producto?.tipo ?? '');

    _descripcionController = TextEditingController(
      text: widget.producto?.descripcion ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_editando && widget.productorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes iniciar sesión como productor para registrar un producto.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final productorId = widget.productorId ?? widget.producto!.productorId;

      final producto = Producto(
        id: widget.producto?.id,
        productorId: productorId,
        nombre: _nombreController.text.trim(),
        tipo: _tipoController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
      );

      if (_editando) {
        await _repository.actualizar(producto);
      } else {
        await _repository.insertar(producto);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el producto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorCrema,
      appBar: AppBar(
        title: Text(
          _editando ? 'Editar producto' : 'Nuevo producto',
          style: const TextStyle(color: colorCafe, fontWeight: FontWeight.w800),
        ),
        backgroundColor: colorCrema,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.agriculture_outlined,
                    color: colorTerracota,
                    size: 30,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Información del producto',
                      style: TextStyle(
                        color: colorCafe,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _nombreController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                hintText: 'Ej. Miel artesanal',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Ingresa el nombre del producto';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _tipoController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Tipo o categoría',
                hintText: 'Ej. Alimento, artesanía...',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Ingresa el tipo de producto';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descripcionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe brevemente el producto...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 65),
                  child: Icon(Icons.description_outlined),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _guardando
                    ? 'Guardando...'
                    : _editando
                    ? 'Guardar cambios'
                    : 'Registrar producto',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorTerracota,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
