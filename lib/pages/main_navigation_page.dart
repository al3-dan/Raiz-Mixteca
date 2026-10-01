import 'package:flutter/material.dart';

import 'productos_page.dart';
import 'productores_page.dart';
import 'qr_escanear_page.dart';

const Color colorFondo = Color(0xFFF5F0E7);
const Color colorCafe = Color(0xFF211B17);
const Color colorTerracota = Color(0xFFB85C38);
const Color colorMiel = Color(0xFFD99A32);
const Color colorVerde = Color(0xFF50634A);
const Color colorBlanco = Color(0xFFFFFDF8);

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _indiceActual = 0;

  final List<Widget> _paginas = const [
    InicioRaizPage(),
    ExplorarPage(),
    ProductoresPage(),
  ];

  void _cambiarPagina(int indice) {
    if (_indiceActual == indice) return;

    setState(() {
      _indiceActual = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      body: IndexedStack(index: _indiceActual, children: _paginas),
      bottomNavigationBar: _BarraNavegacion(
        indiceActual: _indiceActual,
        onChanged: _cambiarPagina,
      ),
    );
  }
}

// ============================================================
// BARRA DE NAVEGACIÓN
// ============================================================

class _BarraNavegacion extends StatelessWidget {
  final int indiceActual;
  final ValueChanged<int> onChanged;

  const _BarraNavegacion({required this.indiceActual, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorBlanco,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 25,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
          child: Row(
            children: [
              _ItemNavegacion(
                icono: Icons.home_outlined,
                iconoActivo: Icons.home_rounded,
                titulo: 'Inicio',
                activo: indiceActual == 0,
                onTap: () => onChanged(0),
              ),
              _ItemNavegacion(
                icono: Icons.explore_outlined,
                iconoActivo: Icons.explore_rounded,
                titulo: 'Explorar',
                activo: indiceActual == 1,
                onTap: () => onChanged(1),
              ),
              _ItemNavegacion(
                icono: Icons.person_outline_rounded,
                iconoActivo: Icons.person_rounded,
                titulo: 'Productor',
                activo: indiceActual == 2,
                onTap: () => onChanged(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemNavegacion extends StatelessWidget {
  final IconData icono;
  final IconData iconoActivo;
  final String titulo;
  final bool activo;
  final VoidCallback onTap;

  const _ItemNavegacion({
    required this.icono,
    required this.iconoActivo,
    required this.titulo,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: activo ? 50 : 42,
                height: 29,
                decoration: BoxDecoration(
                  color: activo
                      ? colorTerracota.withOpacity(.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  activo ? iconoActivo : icono,
                  color: activo ? colorTerracota : const Color(0xFF8E8880),
                  size: 21,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 15,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    titulo,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
                      color: activo ? colorCafe : const Color(0xFF8E8880),
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

// ============================================================
// INICIO
// ============================================================

class InicioRaizPage extends StatelessWidget {
  const InicioRaizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ------------------------------------------------
                  // ENCABEZADO
                  // ------------------------------------------------
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorCafe,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: colorMiel,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RAÍZMIXTECA',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: colorCafe,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Del origen a tus manos',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF756D65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: colorBlanco,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: colorCafe,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // TITULAR
                  // ------------------------------------------------
                  const Text(
                    'Descubre la raíz',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      color: colorCafe,
                    ),
                  ),

                  const SizedBox(height: 9),

                  const Text(
                    'Registra, organiza y conoce los productos que nacen de nuestra tierra.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF756D65),
                    ),
                  ),

                  const SizedBox(height: 23),

                  // ------------------------------------------------
                  // BUSCADOR
                  // ------------------------------------------------
                  _BusquedaInicio(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductosPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ------------------------------------------------
                  // HERO
                  // ------------------------------------------------
                  const _HeroRaiz(),

                  const SizedBox(height: 27),

                  // ------------------------------------------------
                  // EXPLORA
                  // ------------------------------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Text(
                          'RaízMixteca',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: colorCafe,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductosPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Ver productos',
                          style: TextStyle(
                            color: colorTerracota,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ------------------------------------------------
                  // CATEGORÍAS
                  // ------------------------------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CategoriaInicio(
                          icono: Icons.inventory_2_rounded,
                          titulo: 'Productos',
                          color: colorTerracota,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductosPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CategoriaInicio(
                          icono: Icons.person_rounded,
                          titulo: 'Área del productor',
                          color: colorVerde,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductoresPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CategoriaInicio(
                          icono: Icons.qr_code_scanner_rounded,
                          titulo: 'Escanear QR',
                          color: colorCafe,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const QrEscanearPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CategoriaInicio(
                          icono: Icons.verified_rounded,
                          titulo: 'Trazabilidad',
                          color: colorMiel,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductosPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ------------------------------------------------
                  // HISTORIA
                  // ------------------------------------------------
                  const Text(
                    'La historia detrás del producto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: colorCafe,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorCafe,
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: colorMiel.withOpacity(.18),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Icon(
                            Icons.route_rounded,
                            color: colorMiel,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Del productor al origen',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Cada producto puede conservar la historia de quién lo produce, dónde nace y cómo se transforma.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Center(
                    child: Text(
                      'Nuestra tierra · Nuestra historia · Nuestra raíz',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        letterSpacing: .3,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HERO
// ============================================================

class _HeroRaiz extends StatelessWidget {
  const _HeroRaiz();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double ancho = constraints.maxWidth;

        final double tamanoTitulo = ancho < 340 ? 22 : 25;

        return Container(
          height: ancho < 340 ? 220 : 225,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB85C38), Color(0xFF813E29)],
            ),
            boxShadow: [
              BoxShadow(
                color: colorTerracota.withOpacity(.22),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -35,
                top: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.07),
                  ),
                ),
              ),
              Positioned(
                right: 28,
                bottom: -45,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.06),
                  ),
                ),
              ),
              const Positioned(
                left: 22,
                top: 22,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: colorMiel,
                  size: 24,
                ),
              ),
              const Positioned(
                left: 22,
                bottom: 22,
                child: Icon(Icons.eco_rounded, color: Colors.white24, size: 48),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 48, 22, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RAÍZ DE LA MIXTECA',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Tradición que\nse puede rastrear.',
                      maxLines: 2,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: tamanoTitulo,
                        height: 1.08,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _HeroEtiqueta(
                          icono: Icons.verified_rounded,
                          texto: 'Trazabilidad',
                        ),
                        _HeroEtiquetaTexto(texto: 'Origen · Comunidad'),
                      ],
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
}

class _HeroEtiqueta extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _HeroEtiqueta({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: colorMiel, size: 16),
          const SizedBox(width: 7),
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroEtiquetaTexto extends StatelessWidget {
  final String texto;

  const _HeroEtiquetaTexto({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================
// BÚSQUEDA
// ============================================================

class _BusquedaInicio extends StatelessWidget {
  final VoidCallback onTap;

  const _BusquedaInicio({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorBlanco,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: Colors.black.withOpacity(.04)),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: Color(0xFF817970), size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Buscar productos de la Mixteca...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF918981), fontSize: 13),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.tune_rounded, color: colorTerracota, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CATEGORÍAS
// ============================================================

class _CategoriaInicio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Color color;
  final VoidCallback onTap;

  const _CategoriaInicio({
    required this.icono,
    required this.titulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorBlanco,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 78),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icono, color: color, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: colorCafe,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EXPLORAR
// ============================================================

class ExplorarPage extends StatelessWidget {
  const ExplorarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorFondo,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explorar',
              style: TextStyle(
                color: colorCafe,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Productos de nuestra tierra',
              style: TextStyle(color: Color(0xFF817970), fontSize: 11),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          // ------------------------------------------------
          // PRESENTACIÓN
          // ------------------------------------------------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorCafe,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.explore_rounded, color: colorMiel, size: 34),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    'Conoce los productos registrados y descubre la historia que hay detrás de cada uno.',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.4,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------
          // CATÁLOGO
          // ------------------------------------------------
          _BotonExplorar(
            icono: Icons.inventory_2_rounded,
            titulo: 'Catálogo de productos',
            descripcion:
                'Explora los productos registrados por nuestra comunidad.',
            color: colorTerracota,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductosPage()),
              );
            },
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------
          // QR
          // ------------------------------------------------
          _BotonExplorar(
            icono: Icons.qr_code_scanner_rounded,
            titulo: 'Escanear un QR',
            descripcion:
                'Consulta rápidamente la información asociada a un código.',
            color: colorVerde,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrEscanearPage()),
              );
            },
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------
          // TEXTO INFORMATIVO
          // ------------------------------------------------
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorBlanco,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black.withOpacity(.035)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colorTerracota,
                  size: 22,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Aquí podrás consultar información pública de productos y trazabilidad sin necesidad de iniciar sesión.',
                    style: TextStyle(
                      color: Color(0xFF756D65),
                      fontSize: 12,
                      height: 1.45,
                    ),
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

class _BotonExplorar extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;

  const _BotonExplorar({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorBlanco,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(.11),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icono, color: color, size: 27),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        color: colorCafe,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      descripcion,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: Color(0xFF817970),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFAAA29A)),
            ],
          ),
        ),
      ),
    );
  }
}
