import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/mensaje.dart';
import '../models/productor.dart';
import '../repositories/mensaje_repository.dart';

const Color _colorFondo = Color(0xFFF5F0E7);
const Color _colorCafe = Color(0xFF211B17);
const Color _colorTerracota = Color(0xFFB85C38);
const Color _colorMiel = Color(0xFFD99A32);
const Color _colorVerde = Color(0xFF50634A);
const Color _colorBlanco = Color(0xFFFFFDF8);
const Color _colorGris = Color(0xFF817970);

class MensajesPage extends StatefulWidget {
  final Productor productor;

  final int? destinatarioInicialId;
  final String? nombreDestinatarioInicial;
  final String? nombreDestinatario;

  const MensajesPage({
    super.key,
    required this.productor,
    this.destinatarioInicialId,
    this.nombreDestinatarioInicial,
    this.nombreDestinatario,
  });

  @override
  State<MensajesPage> createState() => _MensajesPageState();
}

class _MensajesPageState extends State<MensajesPage>
    with SingleTickerProviderStateMixin {
  final MensajeRepository _repository = MensajeRepository();

  late final TabController _tabController;

  List<Mensaje> _recibidos = [];
  List<Mensaje> _enviados = [];
  Map<int, Productor> _productores = {};

  bool _cargando = true;
  bool _abrioDestinatarioInicial = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _cargarMensajes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARGAR MENSAJES
  // ============================================================

  Future<void> _cargarMensajes() async {
    if (mounted) {
      setState(() {
        _cargando = true;
      });
    }

    try {
      final productorId = widget.productor.id;

      if (productorId == null) {
        throw Exception('El productor no tiene un ID válido.');
      }

      final resultados = await Future.wait([
        _repository.obtenerRecibidos(productorId),
        _repository.obtenerEnviados(productorId),
      ]);

      final recibidos = resultados[0] as List<Mensaje>;
      final enviados = resultados[1] as List<Mensaje>;

      final db = await DatabaseHelper.instance.database;

      final filas = await db.query(
        'productores',
        orderBy: 'nombre COLLATE NOCASE ASC',
      );

      final productores = <int, Productor>{};

      for (final fila in filas) {
        final productor = Productor.fromMap(fila);

        if (productor.id != null) {
          productores[productor.id!] = productor;
        }
      }

      if (!mounted) return;

      setState(() {
        _recibidos = recibidos;
        _enviados = enviados;
        _productores = productores;
        _cargando = false;
      });

      // Abrir automáticamente el contacto cuando venimos
      // desde la comunidad.
      if (!_abrioDestinatarioInicial &&
          widget.destinatarioInicialId != null &&
          widget.destinatarioInicialId != widget.productor.id) {
        _abrioDestinatarioInicial = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final nombre =
              widget.nombreDestinatarioInicial ??
              widget.nombreDestinatario ??
              _nombreProductor(widget.destinatarioInicialId!);

          _mostrarEnviarMensaje(
            destinatarioId: widget.destinatarioInicialId!,
            nombreDestinatario: nombre,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los mensajes: $e')),
      );
    }
  }

  // ============================================================
  // NOMBRE
  // ============================================================

  String _nombreProductor(int id) {
    final productor = _productores[id];

    if (productor == null) {
      return 'Productor';
    }

    return '${productor.nombre} ${productor.apellidos}'.trim();
  }

  // ============================================================
  // FECHA
  // ============================================================

  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      final ahora = DateTime.now();
      final diferencia = ahora.difference(date);

      if (diferencia.inMinutes < 1) {
        return 'Ahora';
      }

      if (diferencia.inMinutes < 60) {
        return 'Hace ${diferencia.inMinutes} min';
      }

      if (diferencia.inHours < 24) {
        return 'Hace ${diferencia.inHours} h';
      }

      if (diferencia.inDays < 7) {
        return 'Hace ${diferencia.inDays} d';
      }

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return fecha;
    }
  }

  // ============================================================
  // ABRIR MENSAJE
  // ============================================================

  Future<void> _abrirMensaje(Mensaje mensaje, bool recibido) async {
    if (recibido && mensaje.leido == 0 && mensaje.id != null) {
      await _repository.marcarComoLeido(mensaje.id!);
    }

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return _DetalleMensaje(
          mensaje: mensaje,
          nombrePersona: recibido
              ? _nombreProductor(mensaje.remitenteId)
              : _nombreProductor(mensaje.destinatarioId),
          fecha: _formatearFecha(mensaje.fecha),
          recibido: recibido,
          onResponder: recibido
              ? () {
                  Navigator.of(context).pop();

                  Future.delayed(const Duration(milliseconds: 180), () {
                    if (!mounted) return;

                    _mostrarEnviarMensaje(
                      destinatarioId: mensaje.remitenteId,
                      nombreDestinatario: _nombreProductor(mensaje.remitenteId),
                    );
                  });
                }
              : null,
        );
      },
    );

    if (mounted) {
      await _cargarMensajes();
    }
  }

  // ============================================================
  // ENVIAR MENSAJE
  // ============================================================

  Future<void> _mostrarEnviarMensaje({
    required int destinatarioId,
    required String nombreDestinatario,
  }) async {
    if (destinatarioId == widget.productor.id) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes enviarte un mensaje a ti mismo.'),
        ),
      );

      return;
    }

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return _FormularioMensaje(
          nombreDestinatario: nombreDestinatario,
          onEnviar: (asunto, contenido) async {
            final remitenteId = widget.productor.id;

            if (remitenteId == null) {
              return false;
            }

            final nuevoMensaje = Mensaje(
              remitenteId: remitenteId,
              destinatarioId: destinatarioId,
              asunto: asunto.trim().isEmpty ? null : asunto.trim(),
              contenido: contenido.trim(),
              fecha: DateTime.now().toIso8601String(),
            );

            try {
              await _repository.insertar(nuevoMensaje);

              if (!mounted) return false;

              await _cargarMensajes();

              return true;
            } catch (e) {
              if (!mounted) return false;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No se pudo enviar el mensaje: $e')),
              );

              return false;
            }
          },
        );
      },
    );
  }

  // ============================================================
  // LISTA
  // ============================================================

  Widget _construirLista(List<Mensaje> mensajes, {required bool recibidos}) {
    if (mensajes.isEmpty) {
      return _EstadoVacio(recibidos: recibidos);
    }

    return RefreshIndicator(
      color: _colorTerracota,
      onRefresh: _cargarMensajes,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        itemCount: mensajes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final mensaje = mensajes[index];

          final personaId = recibidos
              ? mensaje.remitenteId
              : mensaje.destinatarioId;

          return _TarjetaMensaje(
            mensaje: mensaje,
            nombre: _nombreProductor(personaId),
            fecha: _formatearFecha(mensaje.fecha),
            recibido: recibidos,
            onTap: () => _abrirMensaje(mensaje, recibidos),
          );
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorFondo,
      appBar: AppBar(
        backgroundColor: _colorFondo,
        foregroundColor: _colorCafe,
        elevation: 0,
        title: const Text(
          'Mensajes',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargarMensajes,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: _colorBlanco,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: _colorTerracota,
                  borderRadius: BorderRadius.circular(13),
                ),
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: _colorGris,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.inbox_rounded, size: 18),
                    text: 'Recibidos',
                  ),
                  Tab(
                    icon: Icon(Icons.send_rounded, size: 18),
                    text: 'Enviados',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: _colorTerracota),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _construirLista(_recibidos, recibidos: true),
                _construirLista(_enviados, recibidos: false),
              ],
            ),
    );
  }
}

// ================================================================
// FORMULARIO DE MENSAJE
// ================================================================

class _FormularioMensaje extends StatefulWidget {
  final String nombreDestinatario;

  final Future<bool> Function(String asunto, String contenido) onEnviar;

  const _FormularioMensaje({
    required this.nombreDestinatario,
    required this.onEnviar,
  });

  @override
  State<_FormularioMensaje> createState() => _FormularioMensajeState();
}

class _FormularioMensajeState extends State<_FormularioMensaje> {
  late final TextEditingController _asuntoController;
  late final TextEditingController _mensajeController;

  bool _enviando = false;

  @override
  void initState() {
    super.initState();

    _asuntoController = TextEditingController();
    _mensajeController = TextEditingController();
  }

  @override
  void dispose() {
    _asuntoController.dispose();
    _mensajeController.dispose();

    super.dispose();
  }

  Future<void> _enviar() async {
    if (_enviando) return;

    final contenido = _mensajeController.text.trim();

    if (contenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un mensaje primero.')),
      );

      return;
    }

    setState(() {
      _enviando = true;
    });

    final enviado = await widget.onEnviar(_asuntoController.text, contenido);

    if (!mounted) return;

    if (enviado) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mensaje enviado correctamente.'),
          backgroundColor: _colorVerde,
        ),
      );

      return;
    }

    setState(() {
      _enviando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final teclado = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: .76,
      minChildSize: .48,
      maxChildSize: .94,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _colorBlanco,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(20, 12, 20, teclado + 25),
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

                const SizedBox(height: 18),

                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _colorTerracota.withOpacity(.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: _colorTerracota,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nuevo mensaje',
                            style: TextStyle(
                              color: _colorCafe,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Para ${widget.nombreDestinatario}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _colorGris,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: _asuntoController,
                  enabled: !_enviando,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Asunto',
                    prefixIcon: const Icon(Icons.subject_rounded),
                    filled: true,
                    fillColor: _colorFondo,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: _mensajeController,
                  enabled: !_enviando,
                  minLines: 4,
                  maxLines: 7,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Mensaje',
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 55),
                      child: Icon(Icons.message_rounded),
                    ),
                    filled: true,
                    fillColor: _colorFondo,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorTerracota,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    onPressed: _enviando ? null : _enviar,
                    icon: _enviando
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      _enviando ? 'Enviando...' : 'Enviar mensaje',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// TARJETA DE MENSAJE
// ================================================================

class _TarjetaMensaje extends StatelessWidget {
  final Mensaje mensaje;
  final String nombre;
  final String fecha;
  final bool recibido;
  final VoidCallback onTap;

  const _TarjetaMensaje({
    required this.mensaje,
    required this.nombre,
    required this.fecha,
    required this.recibido,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nuevo = recibido && mensaje.leido == 0;

    return Material(
      color: _colorBlanco,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: nuevo
                      ? _colorTerracota.withOpacity(.12)
                      : _colorCafe.withOpacity(.07),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  recibido
                      ? Icons.mark_email_unread_rounded
                      : Icons.send_rounded,
                  color: nuevo ? _colorTerracota : _colorGris,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _colorCafe,
                              fontSize: 14,
                              fontWeight: nuevo
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            fecha,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: Color(0xFF99918A),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (mensaje.asunto != null &&
                        mensaje.asunto!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        mensaje.asunto!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _colorCafe,
                          fontSize: 12.5,
                          fontWeight: nuevo ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 5),

                    Text(
                      mensaje.contenido,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _colorGris,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              if (nuevo) ...[
                const SizedBox(width: 6),
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                    color: _colorTerracota,
                    shape: BoxShape.circle,
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

// ================================================================
// DETALLE
// ================================================================

class _DetalleMensaje extends StatelessWidget {
  final Mensaje mensaje;
  final String nombrePersona;
  final String fecha;
  final bool recibido;
  final VoidCallback? onResponder;

  const _DetalleMensaje({
    required this.mensaje,
    required this.nombrePersona,
    required this.fecha,
    required this.recibido,
    this.onResponder,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .60,
      minChildSize: .35,
      maxChildSize: .90,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _colorBlanco,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
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

                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _colorTerracota.withOpacity(.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: _colorTerracota,
                      ),
                    ),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombrePersona,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _colorCafe,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            fecha,
                            style: const TextStyle(
                              color: _colorGris,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                if (mensaje.asunto != null &&
                    mensaje.asunto!.trim().isNotEmpty) ...[
                  Text(
                    mensaje.asunto!,
                    style: const TextStyle(
                      color: _colorCafe,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _colorFondo,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mensaje.contenido,
                    style: const TextStyle(
                      color: _colorCafe,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                ),

                if (onResponder != null) ...[
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colorTerracota,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: onResponder,
                      icon: const Icon(Icons.reply_rounded),
                      label: const Text(
                        'Responder',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// ESTADO VACÍO
// ================================================================

class _EstadoVacio extends StatelessWidget {
  final bool recibidos;

  const _EstadoVacio({required this.recibidos});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final altura = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 400.0;

        final compacto = altura < 260;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: altura),
            child: Padding(
              padding: EdgeInsets.all(compacto ? 20 : 30),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: compacto ? 64 : 80,
                      height: compacto ? 64 : 80,
                      decoration: BoxDecoration(
                        color: _colorCafe.withOpacity(.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        recibidos
                            ? Icons.mark_email_unread_outlined
                            : Icons.send_outlined,
                        size: compacto ? 30 : 38,
                        color: const Color(0xFF99918A),
                      ),
                    ),

                    SizedBox(height: compacto ? 12 : 18),

                    Text(
                      recibidos
                          ? 'No tienes mensajes'
                          : 'Aún no has enviado mensajes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _colorCafe,
                        fontSize: compacto ? 15 : 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    SizedBox(height: compacto ? 5 : 7),

                    Text(
                      recibidos
                          ? 'Cuando alguien se comunique contigo, aparecerá aquí.'
                          : 'Los mensajes que envíes a otros productores aparecerán aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _colorGris,
                        fontSize: compacto ? 11.5 : 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
