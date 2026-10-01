import 'package:flutter/material.dart';

import '../models/proceso.dart';
import '../repositories/proceso_repository.dart';

class ProcesoPage extends StatefulWidget {
  final int loteId;
  final String codigoLote;

  // true = dueño del lote
  // false = cliente u otro productor
  final bool puedeEditar;

  const ProcesoPage({
    super.key,
    required this.loteId,
    required this.codigoLote,
    this.puedeEditar = true,
  });

  @override
  State<ProcesoPage> createState() => _ProcesoPageState();
}

class _ProcesoPageState extends State<ProcesoPage> {
  final _repository = ProcesoRepository();

  Proceso? _proceso;
  bool _cargando = true;

  static const colorTerracota = Color(0xFFB85C38);
  static const colorCrema = Color(0xFFF5F0E7);
  static const colorCafe = Color(0xFF211B17);
  static const colorVerde = Color(0xFF50634A);
  static const colorDorado = Color(0xFFD99A32);

  @override
  void initState() {
    super.initState();
    _cargarProceso();
  }

  Future<void> _cargarProceso() async {
    try {
      final proceso = await _repository.obtenerPorLote(widget.loteId);

      if (!mounted) return;

      setState(() {
        _proceso = proceso;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar la trazabilidad: $e')),
      );
    }
  }

  Future<void> _mostrarFormulario() async {
    if (!widget.puedeEditar) return;

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
    if (!widget.puedeEditar) return;
    if (_proceso?.id == null) return;

    try {
      await _repository.eliminar(_proceso!.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trazabilidad eliminada correctamente.')),
      );

      await _cargarProceso();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el proceso: $e')),
      );
    }
  }

  Future<void> _confirmarEliminar() async {
    if (!widget.puedeEditar) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar trazabilidad'),
          content: const Text(
            '¿Deseas eliminar todo el proceso registrado para este lote?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.pop(context, true),
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
      backgroundColor: colorCrema,
      appBar: AppBar(
        title: const Text(
          'Trazabilidad',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: widget.puedeEditar
          ? FloatingActionButton.extended(
              onPressed: _mostrarFormulario,
              backgroundColor: colorTerracota,
              foregroundColor: Colors.white,
              icon: Icon(_proceso == null ? Icons.add : Icons.edit_outlined),
              label: Text(_proceso == null ? 'Registrar' : 'Editar'),
            )
          : null,
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: colorTerracota),
            )
          : _proceso == null
          ? _sinProceso()
          : _mostrarProceso(),
    );
  }

  Widget _sinProceso() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
      children: [
        _encabezado(),

        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: colorDorado.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.route_outlined,
                  size: 45,
                  color: colorDorado,
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Aún no hay trazabilidad',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: colorCafe,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.puedeEditar
                    ? 'Registra el recorrido de este lote para mostrar de dónde viene y cómo llegó a convertirse en el producto final.'
                    : 'Este lote todavía no cuenta con información de trazabilidad.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: colorCafe.withOpacity(0.65),
                ),
              ),

              if (widget.puedeEditar) ...[
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _mostrarFormulario,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'REGISTRAR TRAZABILIDAD',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        _etapasPreview(),
      ],
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorCafe, colorCafe.withOpacity(0.88)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorDorado.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  color: colorDorado,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Historia del lote',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            'Lote ${widget.codigoLote}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Del origen a tus manos.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mostrarProceso() {
    final etapas = _obtenerEtapas();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
      children: [
        _encabezado(),

        const SizedBox(height: 22),

        _estadoTrazabilidad(),

        const SizedBox(height: 20),

        if (_proceso!.descripcion != null &&
            _proceso!.descripcion!.trim().isNotEmpty)
          _descripcionCard(),

        if (etapas.isNotEmpty) ...[
          const SizedBox(height: 20),
          _tituloSeccion(
            'Recorrido del producto',
            'Así se transforma desde su origen.',
          ),
          const SizedBox(height: 14),
          _timeline(etapas),
        ],

        if (_proceso!.observaciones != null &&
            _proceso!.observaciones!.trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          _observacionesCard(),
        ],

        if (widget.puedeEditar) ...[
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: _confirmarEliminar,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade200),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text(
              'ELIMINAR TRAZABILIDAD',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ],
    );
  }

  Widget _estadoTrazabilidad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: colorVerde.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorVerde.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorVerde.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_outlined, color: colorVerde),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trazabilidad registrada',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: colorVerde,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Información disponible para consulta.',
                  style: TextStyle(fontSize: 12, color: colorCafe),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _descripcionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion('Sobre este proceso', null),
          const SizedBox(height: 12),
          Text(
            _proceso!.descripcion!,
            style: TextStyle(
              color: colorCafe.withOpacity(0.75),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _observacionesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorDorado.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorDorado.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: colorDorado),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Observaciones',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: colorCafe,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _proceso!.observaciones!,
                  style: TextStyle(
                    color: colorCafe.withOpacity(0.72),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloSeccion(String titulo, String? subtitulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: colorCafe,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitulo != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitulo,
            style: TextStyle(color: colorCafe.withOpacity(0.60), fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _timeline(List<String> etapas) {
    return Column(
      children: List.generate(etapas.length, (index) {
        final esUltima = index == etapas.length - 1;

        return _timelineItem(
          numero: index + 1,
          etapa: etapas[index],
          esUltima: esUltima,
        );
      }),
    );
  }

  Widget _timelineItem({
    required int numero,
    required String etapa,
    required bool esUltima,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: numero == 1 ? colorTerracota : colorVerde,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$numero',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                if (!esUltima)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: colorVerde.withOpacity(0.30),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco_outlined, color: colorVerde, size: 23),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      etapa,
                      style: const TextStyle(
                        color: colorCafe,
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _etapasPreview() {
    const etapas = [
      'Origen',
      'Recolección',
      'Transformación',
      'Envasado',
      'Producto final',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          'Ejemplo de trazabilidad',
          'Una historia clara para cada producto.',
        ),
        const SizedBox(height: 14),
        ...List.generate(
          etapas.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colorVerde.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: colorVerde,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Text(
                  etapas[index],
                  style: const TextStyle(
                    color: colorCafe,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _obtenerEtapas() {
    final texto = _proceso?.etapas;

    if (texto == null || texto.trim().isEmpty) {
      return [];
    }

    return texto
        .split(RegExp(r'[,;\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}

// ============================================================
// FORMULARIO
// ============================================================

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

  static const colorTerracota = Color(0xFFB85C38);
  static const colorCrema = Color(0xFFF5F0E7);
  static const colorCafe = Color(0xFF211B17);
  static const colorVerde = Color(0xFF50634A);

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.proceso == null
                ? 'Trazabilidad registrada correctamente.'
                : 'Trazabilidad actualizada correctamente.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la trazabilidad: $e')),
      );
    }
  }

  Widget _campo(
    String etiqueta,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    IconData? icono,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 19),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: etiqueta,
          hintText: hint,
          prefixIcon: maxLines == 1 && icono != null ? Icon(icono) : null,
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
      backgroundColor: colorCrema,
      appBar: AppBar(
        title: Text(
          editando ? 'Editar trazabilidad' : 'Registrar trazabilidad',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                color: colorCafe,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.route_outlined,
                    color: Color(0xFFD99A32),
                    size: 32,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Cuenta la historia de este lote',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            _campo(
              'Descripción',
              _descripcionController,
              hint: 'Describe brevemente el proceso de producción.',
              maxLines: 4,
            ),

            _campo(
              'Etapas',
              _etapasController,
              hint:
                  'Ejemplo: Origen, Cosecha, Selección, '
                  'Transformación, Envasado.',
              maxLines: 6,
            ),

            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: colorVerde.withOpacity(0.09),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: colorVerde),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Separa cada etapa con comas o escribiéndolas en líneas diferentes. La app las mostrará como una línea de tiempo.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: colorCafe,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _campo(
              'Observaciones',
              _observacionesController,
              hint: 'Agrega información importante sobre el lote.',
              maxLines: 4,
            ),

            const SizedBox(height: 5),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  editando ? 'ACTUALIZAR TRAZABILIDAD' : 'GUARDAR TRAZABILIDAD',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
