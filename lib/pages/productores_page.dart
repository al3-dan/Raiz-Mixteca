import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/productor.dart';
import '../repositories/productor_repository.dart';
import '../repositories/mensaje_repository.dart';
import 'lotes_page.dart';
import 'productos_page.dart';
import 'mensajes_page.dart';

const Color _colorFondo = Color(0xFFF5F0E7);
const Color _colorCrema = Color(0xFFF5F0E7);
const Color _colorTerracota = Color(0xFFB85C38);
const Color _colorTerracotaOscuro = Color(0xFF8F4027);
const Color _colorVerde = Color(0xFF50634A);
const Color _colorTexto = Color(0xFF211B17);
const Color _colorDorado = Color(0xFFD99A32);
const Color _colorBlanco = Color(0xFFFFFDF8);
const Color _colorGris = Color(0xFF817970);

// ============================================================================
// PÁGINA PRINCIPAL DE PRODUCTORES
// ============================================================================

class ProductoresPage extends StatefulWidget {
  const ProductoresPage({super.key});

  @override
  State<ProductoresPage> createState() => _ProductoresPageState();
}

class _ProductoresPageState extends State<ProductoresPage> {
  bool _sesionIniciada = false;
  Productor? _productorActual;

  void _abrirLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductorLoginPage(
          onLoginCorrecto: (productor) {
            if (!mounted) return;

            setState(() {
              _sesionIniciada = true;
              _productorActual = productor;
            });
          },
        ),
      ),
    );
  }

  void _cerrarSesion() {
    setState(() {
      _sesionIniciada = false;
      _productorActual = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión cerrada correctamente.'),
        backgroundColor: _colorVerde,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_sesionIniciada && _productorActual != null) {
      return ProductorPanelPage(
        productor: _productorActual!,
        onCerrarSesion: _cerrarSesion,
      );
    }

    return ProductoresPublicosPage(onIniciarSesion: _abrirLogin);
  }
}

// ============================================================================
// DIRECTORIO PÚBLICO
// ============================================================================

class ProductoresPublicosPage extends StatefulWidget {
  final VoidCallback onIniciarSesion;

  const ProductoresPublicosPage({super.key, required this.onIniciarSesion});

  @override
  State<ProductoresPublicosPage> createState() =>
      _ProductoresPublicosPageState();
}

class _ProductoresPublicosPageState extends State<ProductoresPublicosPage> {
  List<Productor> _productores = [];
  List<Productor> _filtrados = [];

  bool _cargando = true;

  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _cargarProductores();
    _busquedaController.addListener(_filtrar);
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarProductores() async {
    if (mounted) {
      setState(() {
        _cargando = true;
      });
    }

    try {
      final db = await DatabaseHelper.instance.database;

      final filas = await db.query(
        'productores',
        orderBy: 'nombre COLLATE NOCASE ASC',
      );

      final productores = filas.map((fila) => Productor.fromMap(fila)).toList();

      if (!mounted) return;

      setState(() {
        _productores = productores;
        _filtrados = productores;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los productores: $e')),
      );
    }
  }

  void _filtrar() {
    final texto = _busquedaController.text.trim().toLowerCase();

    if (texto.isEmpty) {
      setState(() {
        _filtrados = _productores;
      });
      return;
    }

    setState(() {
      _filtrados = _productores.where((productor) {
        final nombre = '${productor.nombre} ${productor.apellidos}'
            .toLowerCase();

        final comunidad = productor.comunidad.toLowerCase();
        final municipio = productor.municipio.toLowerCase();

        return nombre.contains(texto) ||
            comunidad.contains(texto) ||
            municipio.contains(texto);
      }).toList();
    });
  }

  void _mostrarPerfil(Productor productor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return _PerfilPublicoProductor(productor: productor);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _colorCrema,
      child: Container(
        color: _colorCrema,
        child: RefreshIndicator(
          color: _colorTerracota,
          onRefresh: _cargarProductores,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ======================================================
                      // ENCABEZADO
                      // ======================================================

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'COMUNIDAD',
                                  style: TextStyle(
                                    color: _colorTerracota,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Productores',
                                  style: TextStyle(
                                    color: _colorTexto,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Conoce quién está detrás de cada producto.',
                                  style: TextStyle(
                                    color: _colorGris,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _colorTexto,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.groups_rounded,
                              color: _colorDorado,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ======================================================
                      // ACCESO DE PRODUCTOR
                      // ======================================================
                      Material(
                        color: _colorTexto,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          onTap: widget.onIniciarSesion,
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(17),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: _colorDorado,
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                  child: const Icon(
                                    Icons.agriculture_rounded,
                                    color: Colors.white,
                                    size: 27,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '¿Eres productor?',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Inicia sesión para administrar tus productos y lotes.',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(.72),
                                          fontSize: 11.5,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _colorTerracota,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Text(
                                    'Entrar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ======================================================
                      // REGISTRO
                      // ======================================================
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '¿Aún no tienes cuenta?',
                              style: TextStyle(
                                color: _colorGris.withOpacity(.95),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: widget.onIniciarSesion,
                            style: TextButton.styleFrom(
                              foregroundColor: _colorTerracota,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: const Text(
                              'Crear cuenta',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ======================================================
                      // BUSCADOR
                      // ======================================================
                      TextField(
                        controller: _busquedaController,
                        decoration: InputDecoration(
                          hintText: 'Buscar productor, comunidad...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9B928B),
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: _colorTerracota,
                          ),
                          suffixIcon: _busquedaController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _busquedaController.clear();
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                )
                              : null,
                          filled: true,
                          fillColor: _colorBlanco,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ======================================================
                      // AVISO PÚBLICO
                      // ======================================================
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _colorVerde,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.13),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.public_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Explora información pública de productores de la comunidad.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              if (_cargando)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: _colorTerracota),
                  ),
                )
              else if (_filtrados.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _SinProductores(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final productor = _filtrados[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TarjetaProductorPublico(
                          productor: productor,
                          onTap: () => _mostrarPerfil(productor),
                        ),
                      );
                    }, childCount: _filtrados.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TARJETA PRODUCTOR PÚBLICO
// ============================================================================

class _TarjetaProductorPublico extends StatelessWidget {
  final Productor productor;
  final VoidCallback onTap;

  const _TarjetaProductorPublico({
    required this.productor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = productor.mostrarNombre == 1
        ? '${productor.nombre} ${productor.apellidos}'.trim()
        : 'Productor de RaízMixteca';

    return Material(
      color: _colorBlanco,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_colorTerracota, _colorDorado],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _colorTexto,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: _colorTerracota,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            productor.mostrarComunidad == 1
                                ? '${productor.comunidad}, ${productor.municipio}'
                                : productor.municipio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _colorGris,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (productor.descripcion != null &&
                        productor.descripcion!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        productor.descripcion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _colorGris,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _colorTerracota.withOpacity(.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: _colorTerracota,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PERFIL PÚBLICO
// ============================================================================

class _PerfilPublicoProductor extends StatelessWidget {
  final Productor productor;

  const _PerfilPublicoProductor({required this.productor});

  @override
  Widget build(BuildContext context) {
    final nombre = productor.mostrarNombre == 1
        ? '${productor.nombre} ${productor.apellidos}'.trim()
        : 'Productor de RaízMixteca';

    final ubicacion = productor.mostrarComunidad == 1
        ? '${productor.comunidad}, ${productor.municipio}'
        : productor.municipio;

    return Container(
      constraints: const BoxConstraints(maxHeight: 680),
      decoration: const BoxDecoration(
        color: _colorBlanco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_colorTerracota, _colorDorado],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _colorTexto,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  ubicacion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _colorGris, fontSize: 12.5),
                ),
              ),
              if (productor.descripcion != null &&
                  productor.descripcion!.trim().isNotEmpty) ...[
                const SizedBox(height: 22),
                _CajaDato(
                  icono: Icons.auto_awesome_rounded,
                  titulo: 'Sobre el productor',
                  contenido: productor.descripcion!,
                ),
              ],
              const SizedBox(height: 14),
              _CajaDato(
                icono: Icons.location_on_rounded,
                titulo: 'Ubicación',
                contenido: ubicacion,
              ),
              if (productor.mostrarContacto == 1) ...[
                const SizedBox(height: 14),
                _CajaDato(
                  icono: Icons.contact_phone_rounded,
                  titulo: 'Contacto',
                  contenido: [
                    if (productor.telefono != null &&
                        productor.telefono!.trim().isNotEmpty)
                      'Tel. ${productor.telefono}',
                    if (productor.correo != null &&
                        productor.correo!.trim().isNotEmpty)
                      productor.correo!,
                  ].join('\n'),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _colorCrema,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: _colorVerde),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Productor registrado en RaízMixteca.',
                        style: TextStyle(
                          color: _colorTexto,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

// ============================================================================
// PANEL DEL PRODUCTOR
// ============================================================================

class ProductorPanelPage extends StatefulWidget {
  final Productor productor;
  final VoidCallback onCerrarSesion;

  const ProductorPanelPage({
    super.key,
    required this.productor,
    required this.onCerrarSesion,
  });

  @override
  State<ProductorPanelPage> createState() => _ProductorPanelPageState();
}

class _ProductorPanelPageState extends State<ProductorPanelPage> {
  late Productor _productor;

  int _mensajesNoLeidos = 0;

  final MensajeRepository _mensajeRepository = MensajeRepository();

  @override
  void initState() {
    super.initState();

    _productor = widget.productor;

    _cargarMensajesNoLeidos();
  }

  Future<void> _cargarMensajesNoLeidos() async {
    if (_productor.id == null) return;

    try {
      final cantidad = await _mensajeRepository.contarNoLeidos(_productor.id!);

      if (!mounted) return;

      setState(() {
        _mensajesNoLeidos = cantidad;
      });
    } catch (_) {}
  }

  Future<void> _abrirMensajes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MensajesPage(productor: _productor)),
    );

    await _cargarMensajesNoLeidos();
  }

  void _abrirMisProductos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductosPage(
          productorId: _productor.id,
          productorSesionId: _productor.id,
        ),
      ),
    );
  }

  void _abrirMisLotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LotesPage(
          productorId: _productor.id,
          productorSesionId: _productor.id,
        ),
      ),
    );
  }

  void _abrirComunidad() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoresComunidadPage(productorSesion: _productor),
      ),
    ).then((_) {
      _cargarMensajesNoLeidos();
    });
  }

  Future<void> _editarPerfil() async {
    final actualizado = await Navigator.push<Productor>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductorFormPage(productor: _productor),
      ),
    );

    if (actualizado != null && mounted) {
      setState(() {
        _productor = actualizado;
      });
    }
  }

  void _mostrarPerfil() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return _PerfilPrivado(productor: _productor, onEditar: _editarPerfil);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = '${_productor.nombre} ${_productor.apellidos}'.trim();

    return Material(
      color: _colorCrema,
      child: Container(
        color: _colorCrema,
        child: RefreshIndicator(
          color: _colorTerracota,
          onRefresh: () async {
            await _cargarMensajesNoLeidos();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MI ESPACIO',
                          style: TextStyle(
                            color: _colorTerracota,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Hola, ${_productor.nombre}',
                          style: const TextStyle(
                            color: _colorTexto,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Administra tu presencia en RaízMixteca.',
                          style: TextStyle(color: _colorGris, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _colorTexto,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: _colorDorado,
                      size: 27,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _colorTexto,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _colorTerracota,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_productor.comunidad}, ${_productor.municipio}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(.65),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Mi perfil',
                      onPressed: _mostrarPerfil,
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _colorDorado,
                        size: 17,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Administración',
                style: TextStyle(
                  color: _colorTexto,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ActividadCard(
                    icono: Icons.inventory_2_rounded,
                    titulo: 'Mis productos',
                    subtitulo: 'Catálogo y productos',
                    color: _colorTerracota,
                    onTap: _abrirMisProductos,
                  ),
                  _ActividadCard(
                    icono: Icons.qr_code_2_rounded,
                    titulo: 'Mis lotes',
                    subtitulo: 'Trazabilidad y QR',
                    color: _colorVerde,
                    onTap: _abrirMisLotes,
                  ),
                  _ActividadCard(
                    icono: Icons.groups_rounded,
                    titulo: 'Comunidad',
                    subtitulo: 'Conoce productores',
                    color: _colorDorado,
                    onTap: _abrirComunidad,
                  ),
                  _ActividadCard(
                    icono: Icons.person_outline_rounded,
                    titulo: 'Mi perfil',
                    subtitulo: 'Datos y privacidad',
                    color: _colorTexto,
                    onTap: _mostrarPerfil,
                  ),
                  _ActividadCard(
                    icono: Icons.chat_bubble_rounded,
                    titulo: 'Mensajes',
                    subtitulo: 'Comunícate con productores',
                    color: _colorTerracota,
                    badge: _mensajesNoLeidos,
                    onTap: _abrirMensajes,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _colorBlanco,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _colorVerde.withOpacity(.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        color: _colorVerde,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tu información, tu identidad',
                            style: TextStyle(
                              color: _colorTexto,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Solo puedes modificar tus propios productos, lotes y datos. La información de otros productores es de consulta.',
                            style: TextStyle(
                              color: _colorGris,
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: widget.onCerrarSesion,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _colorTerracota,
                  side: BorderSide(color: _colorTerracota.withOpacity(.35)),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// COMUNIDAD PARA PRODUCTOR LOGUEADO
// ============================================================================

class ProductoresComunidadPage extends StatefulWidget {
  final Productor productorSesion;

  const ProductoresComunidadPage({super.key, required this.productorSesion});

  @override
  State<ProductoresComunidadPage> createState() =>
      _ProductoresComunidadPageState();
}

class _ProductoresComunidadPageState extends State<ProductoresComunidadPage> {
  List<Productor> _productores = [];
  List<Productor> _filtrados = [];

  bool _cargando = true;

  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _cargarProductores();
    _busquedaController.addListener(_filtrar);
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarProductores() async {
    setState(() {
      _cargando = true;
    });

    try {
      final db = await DatabaseHelper.instance.database;

      final filas = await db.query(
        'productores',
        orderBy: 'nombre COLLATE NOCASE ASC',
      );

      final productores = filas.map((fila) => Productor.fromMap(fila)).toList();

      if (!mounted) return;

      setState(() {
        _productores = productores;
        _filtrados = productores;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los productores: $e')),
      );
    }
  }

  void _filtrar() {
    final texto = _busquedaController.text.trim().toLowerCase();

    if (texto.isEmpty) {
      setState(() {
        _filtrados = _productores;
      });
      return;
    }

    setState(() {
      _filtrados = _productores.where((productor) {
        final nombre = '${productor.nombre} ${productor.apellidos}'
            .toLowerCase();

        return nombre.contains(texto) ||
            productor.comunidad.toLowerCase().contains(texto) ||
            productor.municipio.toLowerCase().contains(texto);
      }).toList();
    });
  }

  void _abrirContacto(Productor productor) {
    if (productor.id == null) return;

    if (productor.id == widget.productorSesion.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este es tu propio perfil.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MensajesPage(
          productor: widget.productorSesion,
          destinatarioInicialId: productor.id,
          nombreDestinatario: '${productor.nombre} ${productor.apellidos}'
              .trim(),
        ),
      ),
    );
  }

  void _mostrarPerfil(Productor productor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return _PerfilComunidadProductor(
          productor: productor,
          esPropio: productor.id == widget.productorSesion.id,
          onContactar: productor.id != widget.productorSesion.id
              ? () {
                  Navigator.pop(context);
                  _abrirContacto(productor);
                }
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorCrema,
      appBar: AppBar(
        backgroundColor: _colorCrema,
        foregroundColor: _colorTexto,
        elevation: 0,
        title: const Text(
          'Comunidad',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _cargarProductores,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _colorTerracota,
        onRefresh: _cargarProductores,
        child: _cargando
            ? const Center(
                child: CircularProgressIndicator(color: _colorTerracota),
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
                children: [
                  const Text(
                    'Conecta con otros productores',
                    style: TextStyle(
                      color: _colorTexto,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Consulta información pública y comunícate directamente con la comunidad.',
                    style: TextStyle(
                      color: _colorGris,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar productor...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _colorTerracota,
                      ),
                      filled: true,
                      fillColor: _colorBlanco,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_filtrados.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: _SinProductores(),
                    )
                  else
                    ..._filtrados.map(
                      (productor) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TarjetaComunidad(
                          productor: productor,
                          esPropio: productor.id == widget.productorSesion.id,
                          onVerPerfil: () => _mostrarPerfil(productor),
                          onContactar: productor.id != widget.productorSesion.id
                              ? () => _abrirContacto(productor)
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

// ============================================================================
// TARJETA COMUNIDAD
// ============================================================================

class _TarjetaComunidad extends StatelessWidget {
  final Productor productor;
  final bool esPropio;
  final VoidCallback onVerPerfil;
  final VoidCallback? onContactar;

  const _TarjetaComunidad({
    required this.productor,
    required this.esPropio,
    required this.onVerPerfil,
    required this.onContactar,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = productor.mostrarNombre == 1
        ? '${productor.nombre} ${productor.apellidos}'.trim()
        : 'Productor de RaízMixteca';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorBlanco,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: esPropio ? _colorVerde : _colorTerracota,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _colorTexto,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (esPropio) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _colorVerde.withOpacity(.10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'TÚ',
                              style: TextStyle(
                                color: _colorVerde,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: _colorTerracota,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${productor.comunidad}, ${productor.municipio}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _colorGris,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onVerPerfil,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _colorTexto,
                    side: BorderSide(color: _colorTexto.withOpacity(.12)),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.person_search_rounded, size: 18),
                  label: const Text(
                    'Ver perfil',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
              if (onContactar != null) ...[
                const SizedBox(width: 9),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onContactar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorTerracota,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.chat_rounded, size: 18),
                    label: const Text(
                      'Contactar',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PERFIL DE COMUNIDAD
// ============================================================================

class _PerfilComunidadProductor extends StatelessWidget {
  final Productor productor;
  final bool esPropio;
  final VoidCallback? onContactar;

  const _PerfilComunidadProductor({
    required this.productor,
    required this.esPropio,
    required this.onContactar,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = productor.mostrarNombre == 1
        ? '${productor.nombre} ${productor.apellidos}'.trim()
        : 'Productor de RaízMixteca';

    final ubicacion = productor.mostrarComunidad == 1
        ? '${productor.comunidad}, ${productor.municipio}'
        : productor.municipio;

    return Container(
      constraints: const BoxConstraints(maxHeight: 700),
      decoration: const BoxDecoration(
        color: _colorBlanco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: esPropio ? _colorVerde : _colorTerracota,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 39,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _colorTexto,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (esPropio) ...[
                const SizedBox(height: 6),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _colorVerde.withOpacity(.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'TU PERFIL',
                      style: TextStyle(
                        color: _colorVerde,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Center(
                child: Text(
                  ubicacion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _colorGris, fontSize: 12),
                ),
              ),
              const SizedBox(height: 22),
              if (productor.descripcion != null &&
                  productor.descripcion!.trim().isNotEmpty)
                _CajaDato(
                  icono: Icons.auto_awesome_rounded,
                  titulo: 'Sobre el productor',
                  contenido: productor.descripcion!,
                ),
              const SizedBox(height: 12),
              _CajaDato(
                icono: Icons.location_on_rounded,
                titulo: 'Ubicación',
                contenido: ubicacion,
              ),
              if (productor.mostrarContacto == 1) ...[
                const SizedBox(height: 12),
                _CajaDato(
                  icono: Icons.contact_phone_rounded,
                  titulo: 'Contacto',
                  contenido: [
                    if (productor.telefono != null &&
                        productor.telefono!.trim().isNotEmpty)
                      'Tel. ${productor.telefono}',
                    if (productor.correo != null &&
                        productor.correo!.trim().isNotEmpty)
                      productor.correo!,
                  ].join('\n'),
                ),
              ],
              if (onContactar != null) ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onContactar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorTerracota,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    icon: const Icon(Icons.chat_rounded),
                    label: const Text(
                      'Contactar productor',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
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

// ============================================================================
// LOGIN
// ============================================================================

class ProductorLoginPage extends StatefulWidget {
  final ValueChanged<Productor> onLoginCorrecto;

  const ProductorLoginPage({super.key, required this.onLoginCorrecto});

  @override
  State<ProductorLoginPage> createState() => _ProductorLoginPageState();
}

class _ProductorLoginPageState extends State<ProductorLoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();

  bool _mostrarContrasena = false;
  bool _cargando = false;

  final ProductorRepository _repository = ProductorRepository();

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      final productor = await _repository.iniciarSesion(
        _usuarioController.text.trim(),
        _contrasenaController.text,
      );

      if (!mounted) return;

      if (productor == null) {
        setState(() {
          _cargando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos.')),
        );

        return;
      }

      widget.onLoginCorrecto(productor);

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo iniciar sesión: $e')));
    }
  }

  void _abrirRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductorFormPage(
          onGuardado: (productor) {
            if (!mounted) return;

            _usuarioController.text = productor.usuario;
            _contrasenaController.text = productor.contrasena;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cuenta creada. Ahora inicia sesión.'),
                backgroundColor: _colorVerde,
              ),
            );
          },
        ),
      ),
    );
  }

  void _mostrarAyuda() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
          decoration: const BoxDecoration(
            color: _colorBlanco,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Acceso de productor',
                  style: TextStyle(
                    color: _colorTexto,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Utiliza el usuario y contraseña que registraste para administrar tus productos, lotes, perfil y mensajes.',
                  style: TextStyle(
                    color: _colorGris,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorTerracota,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Entendido'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorCrema,
      appBar: AppBar(
        backgroundColor: _colorCrema,
        foregroundColor: _colorTexto,
        elevation: 0,
        title: const Text(
          'Acceso de productor',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _mostrarAyuda,
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _colorBlanco,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: _colorTerracota,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.agriculture_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Bienvenido',
                        style: TextStyle(
                          color: _colorTexto,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Center(
                      child: Text(
                        'Ingresa a tu espacio de productor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _colorGris, fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(height: 25),
                    _CampoLogin(
                      controller: _usuarioController,
                      label: 'Usuario',
                      icono: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Escribe tu usuario.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 13),
                    _CampoLogin(
                      controller: _contrasenaController,
                      label: 'Contraseña',
                      icono: Icons.lock_outline_rounded,
                      obscureText: !_mostrarContrasena,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _mostrarContrasena = !_mostrarContrasena;
                          });
                        },
                        icon: Icon(
                          _mostrarContrasena
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Escribe tu contraseña.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _iniciarSesion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorTerracota,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _colorTerracota.withOpacity(
                            .5,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: _cargando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _abrirRegistro,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _colorTexto,
                          side: BorderSide(color: _colorTexto.withOpacity(.14)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text(
                          'Crear cuenta',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FORMULARIO PRODUCTOR
// ============================================================================

class ProductorFormPage extends StatefulWidget {
  final Productor? productor;
  final ValueChanged<Productor>? onGuardado;

  const ProductorFormPage({super.key, this.productor, this.onGuardado});

  @override
  State<ProductorFormPage> createState() => _ProductorFormPageState();
}

class _ProductorFormPageState extends State<ProductorFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _comunidadController = TextEditingController();
  final _municipioController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();

  final ProductorRepository _repository = ProductorRepository();

  bool _mostrarNombre = true;
  bool _mostrarComunidad = true;
  bool _mostrarContacto = false;

  bool _cargando = false;

  bool get _esEdicion => widget.productor != null;

  @override
  void initState() {
    super.initState();

    final productor = widget.productor;

    if (productor != null) {
      _nombreController.text = productor.nombre;
      _apellidosController.text = productor.apellidos;
      _comunidadController.text = productor.comunidad;
      _municipioController.text = productor.municipio;
      _telefonoController.text = productor.telefono ?? '';
      _correoController.text = productor.correo ?? '';
      _descripcionController.text = productor.descripcion ?? '';
      _usuarioController.text = productor.usuario;
      _contrasenaController.text = productor.contrasena;

      _mostrarNombre = productor.mostrarNombre == 1;
      _mostrarComunidad = productor.mostrarComunidad == 1;
      _mostrarContacto = productor.mostrarContacto == 1;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _comunidadController.dispose();
    _municipioController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _descripcionController.dispose();
    _usuarioController.dispose();
    _contrasenaController.dispose();

    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      final usuario = _usuarioController.text.trim();

      final existe = await _repository.existeUsuario(
        usuario,
        excluirId: widget.productor?.id,
      );

      if (existe) {
        if (!mounted) return;

        setState(() {
          _cargando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ese usuario ya está registrado.')),
        );

        return;
      }

      final productor = Productor(
        id: widget.productor?.id,
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
        usuario: usuario,
        contrasena: _contrasenaController.text,
        mostrarNombre: _mostrarNombre ? 1 : 0,
        mostrarComunidad: _mostrarComunidad ? 1 : 0,
        mostrarContacto: _mostrarContacto ? 1 : 0,
        fechaRegistro:
            widget.productor?.fechaRegistro ?? DateTime.now().toIso8601String(),
      );

      if (_esEdicion) {
        await _repository.actualizar(productor);
      } else {
        await _repository.insertar(productor);
      }

      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      widget.onGuardado?.call(productor);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Perfil actualizado correctamente.'
                : 'Cuenta creada correctamente.',
          ),
          backgroundColor: _colorVerde,
        ),
      );

      if (_esEdicion) {
        Navigator.pop(context, productor);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorCrema,
      appBar: AppBar(
        backgroundColor: _colorCrema,
        foregroundColor: _colorTexto,
        elevation: 0,
        title: Text(
          _esEdicion ? 'Editar perfil' : 'Crear cuenta',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
            children: [
              _SeccionTitulo(
                titulo: 'Datos personales',
                subtitulo: 'Información básica de tu perfil.',
              ),
              _CampoFormulario(
                controller: _nombreController,
                label: 'Nombre',
                icono: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Escribe tu nombre.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 11),
              _CampoFormulario(
                controller: _apellidosController,
                label: 'Apellidos',
                icono: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Escribe tus apellidos.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 11),
              _CampoFormulario(
                controller: _comunidadController,
                label: 'Comunidad',
                icono: Icons.home_work_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Escribe tu comunidad.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 11),
              _CampoFormulario(
                controller: _municipioController,
                label: 'Municipio',
                icono: Icons.location_on_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Escribe tu municipio.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 11),
              _CampoFormulario(
                controller: _telefonoController,
                label: 'Teléfono',
                icono: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 11),
              _CampoFormulario(
                controller: _correoController,
                label: 'Correo',
                icono: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 11),
              _CampoFormulario(
                controller: _descripcionController,
                label: 'Descripción del productor',
                icono: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 25),
              _SeccionTitulo(
                titulo: 'Acceso',
                subtitulo: 'Datos para entrar a tu espacio.',
              ),
              _CampoFormulario(
                controller: _usuarioController,
                label: 'Usuario',
                icono: Icons.account_circle_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Escribe un usuario.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 11),
              _CampoFormulario(
                controller: _contrasenaController,
                label: 'Contraseña',
                icono: Icons.lock_outline_rounded,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Escribe una contraseña.';
                  }

                  if (value.length < 4) {
                    return 'Mínimo 4 caracteres.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 25),
              _SeccionTitulo(
                titulo: 'Privacidad',
                subtitulo: 'Tú decides qué información será visible.',
              ),
              _SwitchPrivacidad(
                titulo: 'Mostrar mi nombre',
                subtitulo: 'Permite que aparezca tu nombre en la comunidad.',
                valor: _mostrarNombre,
                onChanged: (valor) {
                  setState(() {
                    _mostrarNombre = valor;
                  });
                },
              ),
              _SwitchPrivacidad(
                titulo: 'Mostrar comunidad',
                subtitulo: 'Permite mostrar tu comunidad públicamente.',
                valor: _mostrarComunidad,
                onChanged: (valor) {
                  setState(() {
                    _mostrarComunidad = valor;
                  });
                },
              ),
              _SwitchPrivacidad(
                titulo: 'Mostrar contacto',
                subtitulo: 'Permite mostrar teléfono y correo.',
                valor: _mostrarContacto,
                onChanged: (valor) {
                  setState(() {
                    _mostrarContacto = valor;
                  });
                },
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _cargando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorTerracota,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  icon: _cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _esEdicion ? 'Guardar cambios' : 'Crear cuenta',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGETS
// ============================================================================

class _ActividadCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;
  final int badge;

  const _ActividadCard({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _colorBlanco,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ============================================================
              // CONTENIDO PRINCIPAL
              // ============================================================
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICONO
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.11),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icono, color: color, size: 21),
                  ),

                  const SizedBox(height: 8),

                  // TÍTULO
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _colorTexto,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // DESCRIPCIÓN
                  Text(
                    subtitulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _colorGris,
                      fontSize: 9.5,
                      height: 1.15,
                    ),
                  ),
                ],
              ),

              // ============================================================
              // BADGE DE MENSAJES
              // ============================================================
              if (badge > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 21,
                      minHeight: 21,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _colorTerracota,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _colorBlanco, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CajaDato extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String contenido;

  const _CajaDato({
    required this.icono,
    required this.titulo,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _colorCrema,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _colorTerracota.withOpacity(.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icono, color: _colorTerracota, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: _colorTexto,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contenido,
                  style: const TextStyle(
                    color: _colorGris,
                    fontSize: 12,
                    height: 1.4,
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

class _CampoLogin extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icono;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _CampoLogin({
    required this.controller,
    required this.label,
    required this.icono,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _colorCrema,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CampoFormulario extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icono;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _CampoFormulario({
    required this.controller,
    required this.label,
    required this.icono,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      validator: validator,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 45 : 0),
          child: Icon(icono),
        ),
        filled: true,
        fillColor: _colorBlanco,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const _SeccionTitulo({required this.titulo, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: _colorTexto,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitulo,
            style: const TextStyle(color: _colorGris, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _SwitchPrivacidad extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const _SwitchPrivacidad({
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _colorBlanco,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: _colorTexto,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    color: _colorGris,
                    fontSize: 10.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: valor,
            activeColor: _colorTerracota,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DatoPerfil extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;

  const _DatoPerfil({
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _colorCrema,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Icon(icono, color: _colorTerracota, size: 21),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(color: _colorGris, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    color: _colorTexto,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _PerfilPrivado extends StatelessWidget {
  final Productor productor;
  final VoidCallback onEditar;

  const _PerfilPrivado({required this.productor, required this.onEditar});

  @override
  Widget build(BuildContext context) {
    final nombre = '${productor.nombre} ${productor.apellidos}'.trim();

    return Container(
      constraints: const BoxConstraints(maxHeight: 700),
      decoration: const BoxDecoration(
        color: _colorBlanco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: _colorTexto,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: _colorDorado,
                    size: 39,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _colorTexto,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  '${productor.comunidad}, ${productor.municipio}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _colorGris, fontSize: 12),
                ),
              ),
              const SizedBox(height: 22),
              _DatoPerfil(
                titulo: 'Usuario',
                valor: productor.usuario,
                icono: Icons.account_circle_outlined,
              ),
              _DatoPerfil(
                titulo: 'Teléfono',
                valor: productor.telefono ?? 'No registrado',
                icono: Icons.phone_outlined,
              ),
              _DatoPerfil(
                titulo: 'Correo',
                valor: productor.correo ?? 'No registrado',
                icono: Icons.email_outlined,
              ),
              if (productor.descripcion != null &&
                  productor.descripcion!.trim().isNotEmpty)
                _DatoPerfil(
                  titulo: 'Descripción',
                  valor: productor.descripcion!,
                  icono: Icons.description_outlined,
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onEditar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _colorTerracota,
                    side: BorderSide(color: _colorTerracota.withOpacity(.35)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text(
                    'Editar mi perfil',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SinProductores extends StatelessWidget {
  const _SinProductores();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: _colorTexto.withOpacity(.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups_outlined,
                size: 38,
                color: Color(0xFF99918A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No encontramos productores',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _colorTexto,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Prueba con otro nombre, comunidad o municipio.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _colorGris, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
