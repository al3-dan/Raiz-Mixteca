class Proceso {
  final int? id;
  final int loteId;
  final String? descripcion;
  final String? etapas;
  final String? observaciones;

  Proceso({
    this.id,
    required this.loteId,
    this.descripcion,
    this.etapas,
    this.observaciones,
  });

  factory Proceso.fromMap(Map<String, dynamic> map) {
    return Proceso(
      id: map['id'] as int?,
      loteId: map['lote_id'] as int,
      descripcion: map['descripcion'] as String?,
      etapas: map['etapas'] as String?,
      observaciones: map['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lote_id': loteId,
      'descripcion': descripcion,
      'etapas': etapas,
      'observaciones': observaciones,
    };
  }
}
