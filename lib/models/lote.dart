class Lote {
  final int? id;
  final int productoId;
  final String codigoLote;
  final String fechaProduccion;
  final String? descripcion;

  Lote({
    this.id,
    required this.productoId,
    required this.codigoLote,
    required this.fechaProduccion,
    this.descripcion,
  });

  factory Lote.fromMap(Map<String, dynamic> map) {
    return Lote(
      id: map['id'] as int?,
      productoId: map['producto_id'] as int,
      codigoLote: map['codigo_lote'] as String,
      fechaProduccion: map['fecha_produccion'] as String,
      descripcion: map['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto_id': productoId,
      'codigo_lote': codigoLote,
      'fecha_produccion': fechaProduccion,
      'descripcion': descripcion,
    };
  }
}
