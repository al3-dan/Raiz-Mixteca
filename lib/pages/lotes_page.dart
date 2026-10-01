import 'package:flutter/material.dart';

import '../models/lote.dart';
import '../models/producto.dart';
import '../models/productor.dart';
import '../repositories/lote_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/productor_repository.dart';
import 'fotografias_page.dart';
import 'proceso_page.dart';
import 'qr_generar_page.dart';

class LotesPage extends StatefulWidget {
  /// Si se especifica, muestra solamente los lotes relacionados
  /// con los productos de este productor.
  final int? productorId;

  /// Identidad del productor que inició sesión.
  /// Sirve para determinar qué acciones puede realizar.
  final int? productorSesionId;

  const LotesPage({super.key, this.productorId, this.productorSesionId});

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

  static const Color colorTierra = Color(0xFF6B4226);
  static const Color colorBarro = Color(0xFFA85D3A);
  static const Color colorVerde = Color(0xFF667C4A);
  static const Color colorDorado = Color(0xFFD5A84B);
  static const Color colorCrema = Color(0xFFF7F1E5);
  static const Color colorTexto = Color(0xFF30251F);

  bool get _esVisitante => widget.productorSesionId == null;

  bool _esPropietario(Lote lote) {
    if (widget.productorSesionId == null) {
      return false;
    }

    final producto = _productos[lote.productoId];

    if (producto == null) {
      return false;
    }

    return producto.productorId == widget.productorSesionId;
  }

  bool get _puedeAgregar {
    return widget.productorSesionId != null;
  }

  String get _tituloLista {
    if (widget.productorId != null) {
      return 'Mis lotes';
    }

    if (_esVisitante) {
      return 'Lotes registrados';
    }

    return 'Lotes públicos';
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      List<Lote> lotes;
      List<Producto> productos;
      List<Productor> productores;

      if (widget.productorId != null) {
        productos = await _productoRepository.obtenerPorProductor(
          widget.productorId!,
        );

        lotes = [];

        for (final producto in productos) {
          if (producto.id == null) continue;

          final lotesProducto = await _loteRepository.obtenerPorProducto(
            producto.id!,
          );

          lotes.addAll(lotesProducto);
        }

        final productor = await _productorRepository.obtenerPorId(
          widget.productorId!,
        );

        productores = productor == null ? [] : [productor];
      } else {
        lotes = await _loteRepository.obtenerTodos();
        productos = await _productoRepository.obtenerTodos();
        productores = await _productorRepository.obtenerTodos();
      }

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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudieron cargar los lotes: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorTierra,
        ),
      );
    }
  }

  Future<void> _mostrarFormulario() async {
    if (!_puedeAgregar) {
      _mostrarMensaje(
        'Debes iniciar sesión como productor para registrar un lote.',
      );
      return;
    }

    final productosPropios = _productos.values
        .where(
          (producto) =>
              producto.productorId == widget.productorSesionId &&
              producto.id != null,
        )
        .toList();

    if (productosPropios.isEmpty) {
      _mostrarMensaje('Primero debes registrar al menos un producto propio.');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoteFormPage(productos: productosPropios),
      ),
    );

    if (!mounted) return;

    await _cargarDatos();
  }

  Future<void> _eliminarLote(Lote lote) async {
    if (!_esPropietario(lote)) {
      _mostrarMensaje('Solo puedes eliminar tus propios lotes.');
      return;
    }

    if (lote.id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Eliminar lote',
            style: TextStyle(fontWeight: FontWeight.bold, color: colorTexto),
          ),
          content: Text(
            '¿Deseas eliminar el lote ${lote.codigoLote}? '
            'También se eliminarán los datos relacionados.',
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
      await _loteRepository.eliminar(lote.id!);

      if (!mounted) return;

      await _cargarDatos();

      if (!mounted) return;

      _mostrarMensaje('Lote eliminado correctamente.');
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje('No se pudo eliminar el lote: $e');
    }
  }

  void _abrirDetalle(Lote lote) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoteDetallePage(
          lote: lote,
          producto: _productos[lote.productoId],
          productor: _obtenerProductorDelProducto(lote.productoId),
          puedeEditar: _esPropietario(lote),
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
        elevation: 0,
        backgroundColor: colorCrema,
        foregroundColor: colorTexto,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RAÍZMIXTECA',
              style: TextStyle(
                color: colorVerde,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Lotes y trazabilidad',
              style: TextStyle(
                color: colorTexto,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _puedeAgregar
          ? FloatingActionButton.extended(
              onPressed: _mostrarFormulario,
              backgroundColor: colorTierra,
              foregroundColor: Colors.white,
              elevation: 5,
              icon: const Icon(Icons.add),
              label: const Text(
                'Nuevo lote',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: colorTierra))
          : _lotes.isEmpty
          ? _estadoVacio()
          : RefreshIndicator(
              color: colorTierra,
              onRefresh: _cargarDatos,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
                children: [
                  _encabezado(),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _tituloLista,
                          style: const TextStyle(
                            color: colorTexto,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: colorDorado.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '${_lotes.length} registrados',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: colorTierra,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ..._lotes.map(_tarjetaLote),
                ],
              ),
            ),
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [colorTierra, colorBarro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorTierra.withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -35,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 20,
                ),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -55,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 15,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Trazabilidad\ndesde la raíz.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Conoce el recorrido de cada producto '
                'desde su origen.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaLote(Lote lote) {
    final producto = _productos[lote.productoId];
    final productor = _obtenerProductorDelProducto(lote.productoId);
    final esPropio = _esPropietario(lote);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: esPropio
              ? colorVerde.withOpacity(0.20)
              : colorTierra.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _abrirDetalle(lote),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: colorTierra.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      color: colorTierra,
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
                                'CÓDIGO DEL LOTE',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: colorVerde,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            if (esPropio) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorVerde.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'MÍO',
                                  style: TextStyle(
                                    color: colorVerde,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lote.codigoLote,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: colorTexto,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (esPropio) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        tooltip: 'Eliminar lote',
                        padding: EdgeInsets.zero,
                        onPressed: () => _eliminarLote(lote),
                        style: IconButton.styleFrom(
                          backgroundColor: colorBarro.withOpacity(0.10),
                          foregroundColor: colorBarro,
                        ),
                        icon: const Icon(Icons.delete_outline, size: 20),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 17),
              const Divider(height: 1),
              const SizedBox(height: 16),

              _datoVisual(
                Icons.inventory_2_outlined,
                'Producto',
                producto?.nombre ?? 'Desconocido',
              ),

              const SizedBox(height: 12),

              _datoVisual(
                Icons.person_outline,
                'Productor',
                productor == null
                    ? 'Desconocido'
                    : '${productor.nombre} ${productor.apellidos}',
              ),

              const SizedBox(height: 12),

              _datoVisual(
                Icons.calendar_today_outlined,
                'Producción',
                lote.fechaProduccion,
              ),

              const SizedBox(height: 17),

              _botonAccion(
                icono: Icons.arrow_forward_rounded,
                texto: 'Ver trazabilidad',
                onTap: () => _abrirDetalle(lote),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datoVisual(IconData icono, String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colorVerde.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, size: 18, color: colorVerde),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: colorTexto,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _botonAccion({
    required IconData icono,
    required String texto,
    required VoidCallback onTap,
  }) {
    return Material(
      color: colorCrema,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            children: [
              Icon(icono, color: colorTierra, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: colorTierra,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: colorTierra, size: 21),
            ],
          ),
        ),
      ),
    );
  }

  Widget _estadoVacio() {
    final mensaje = _esVisitante
        ? 'Todavía no hay lotes registrados en RaízMixteca.'
        : 'Registra tu primer lote para comenzar '
              'a construir su trazabilidad.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: colorTierra.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 50,
                color: colorTierra,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _esVisitante ? 'Aún no hay lotes' : 'Aún no tienes lotes',
              style: const TextStyle(
                color: colorTexto,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                height: 1.5,
                fontSize: 14,
              ),
            ),
            if (_puedeAgregar) ...[
              const SizedBox(height: 25),
              FilledButton.icon(
                onPressed: _mostrarFormulario,
                style: FilledButton.styleFrom(
                  backgroundColor: colorTierra,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Registrar primer lote',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
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

  final _descripcionController = TextEditingController();

  int? _productoSeleccionado;
  DateTime? _fechaProduccion;
  String _codigoGenerado = '';
  bool _guardando = false;

  static const Color colorTierra = Color(0xFF6B4226);
  static const Color colorBarro = Color(0xFFA85D3A);
  static const Color colorVerde = Color(0xFF667C4A);
  static const Color colorCrema = Color(0xFFF7F1E5);
  static const Color colorTexto = Color(0xFF30251F);

  @override
  void initState() {
    super.initState();
    _cargarCodigoGenerado();
  }

  Future<void> _cargarCodigoGenerado() async {
    final codigo = await _repository.generarSiguienteCodigo();

    if (!mounted) return;

    setState(() {
      _codigoGenerado = codigo;
    });
  }

  @override
  void dispose() {
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
    if (_guardando) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaProduccion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la fecha de producción.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorTierra,
        ),
      );
      return;
    }

    if (_productoSeleccionado == null) {
      return;
    }

    final fecha = _fechaProduccion!;

    final lote = Lote(
      productoId: _productoSeleccionado!,
      codigoLote: _codigoGenerado,
      fechaProduccion:
          '${fecha.year.toString().padLeft(4, '0')}-'
          '${fecha.month.toString().padLeft(2, '0')}-'
          '${fecha.day.toString().padLeft(2, '0')}',
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
    );

    setState(() {
      _guardando = true;
    });

    try {
      await _repository.insertar(lote);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar el lote: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorBarro,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorCrema,
      appBar: AppBar(
        backgroundColor: colorCrema,
        foregroundColor: colorTexto,
        elevation: 0,
        title: const Text(
          'Registrar lote',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [colorTierra, colorBarro],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.qr_code_2, color: Colors.white, size: 34),
                  const SizedBox(height: 14),
                  const Text(
                    'Nuevo lote',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _codigoGenerado.isEmpty
                        ? 'Generando código del lote...'
                        : 'Código generado: $_codigoGenerado',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<int>(
              initialValue: _productoSeleccionado,
              decoration: InputDecoration(
                labelText: 'Producto',
                prefixIcon: const Icon(
                  Icons.inventory_2_outlined,
                  color: colorVerde,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: BorderSide.none,
                ),
              ),
              items: widget.productos.map((producto) {
                return DropdownMenuItem<int>(
                  value: producto.id,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Text(
                      producto.nombre,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
              borderRadius: BorderRadius.circular(17),
              onTap: _seleccionarFecha,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Fecha de producción',
                  prefixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    color: colorVerde,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: BorderSide.none,
                  ),
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
              decoration: InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 55),
                  child: Icon(Icons.notes_outlined, color: colorVerde),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorTierra,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: colorTierra.withOpacity(0.45),
                  disabledForegroundColor: Colors.white70,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: _guardando
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _guardando ? 'GUARDANDO...' : 'GUARDAR LOTE',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
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
  final bool puedeEditar;

  const LoteDetallePage({
    super.key,
    required this.lote,
    required this.producto,
    required this.productor,
    required this.puedeEditar,
  });

  static const Color colorTierra = Color(0xFF6B4226);
  static const Color colorBarro = Color(0xFFA85D3A);
  static const Color colorVerde = Color(0xFF667C4A);
  static const Color colorDorado = Color(0xFFD5A84B);
  static const Color colorCrema = Color(0xFFF7F1E5);
  static const Color colorTexto = Color(0xFF30251F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorCrema,
      appBar: AppBar(
        backgroundColor: colorCrema,
        foregroundColor: colorTexto,
        elevation: 0,
        title: Text(
          'Lote ${lote.codigoLote}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [colorTierra, colorBarro]),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    color: Colors.white,
                    size: 31,
                  ),
                ),

                const SizedBox(height: 17),

                const Text(
                  'INFORMACIÓN DEL LOTE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  lote.codigoLote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    puedeEditar
                        ? 'Lote propio · puedes gestionar evidencias'
                        : 'Información pública',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(23),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _dato('Código de lote', lote.codigoLote),
                _dato('Producto', producto?.nombre ?? 'Desconocido'),
                _dato('Tipo', producto?.tipo ?? 'Desconocido'),
                _dato(
                  'Productor',
                  productor == null
                      ? 'Desconocido'
                      : '${productor!.nombre} ${productor!.apellidos}',
                ),
                _dato('Comunidad', productor?.comunidad ?? 'Desconocida'),
                _dato('Municipio', productor?.municipio ?? 'Desconocido'),
                _dato('Fecha de producción', lote.fechaProduccion),
                if (lote.descripcion != null && lote.descripcion!.isNotEmpty)
                  _dato('Descripción', lote.descripcion!),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Explora el lote',
            style: TextStyle(
              color: colorTexto,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            puedeEditar
                ? 'Administra la información y evidencias de tu lote.'
                : 'Consulta la información pública de trazabilidad.',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const SizedBox(height: 14),

          if (puedeEditar) ...[
            _opcion(
              context,
              icono: Icons.account_tree_outlined,
              titulo: 'Proceso de producción',
              subtitulo: 'Registrar las etapas del proceso.',
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
            const SizedBox(height: 12),
          ],

          if (puedeEditar) ...[
            _opcion(
              context,
              icono: Icons.photo_library_outlined,
              titulo: 'Fotografías',
              subtitulo: 'Agregar evidencias fotográficas.',
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
            const SizedBox(height: 12),
          ],

          _opcion(
            context,
            icono: Icons.qr_code_2,
            titulo: 'Generar QR del lote',
            subtitulo: 'Muestra y comparte el código QR.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QrGenerarPage(lote: lote)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5, right: 12),
            decoration: const BoxDecoration(
              color: colorDorado,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  valor,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: colorTexto,
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

  Widget _opcion(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorTierra.withOpacity(0.07)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorTierra.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icono, color: colorTierra, size: 26),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: colorTexto,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorCrema,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: colorTierra,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
