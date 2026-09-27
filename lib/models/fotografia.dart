class Fotografia {
  final int? id;
  final int loteId;
  final String ruta;
  final String? descripcion;

  Fotografia({
    this.id,
    required this.loteId,
    required this.ruta,
    this.descripcion,
  });

  factory Fotografia.fromMap(Map<String, dynamic> map) {
    return Fotografia(
      id: map['id'] as int?,
      loteId: map['lote_id'] as int,
      ruta: map['ruta'] as String,
      descripcion: map['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lote_id': loteId,
      'ruta': ruta,
      'descripcion': descripcion,
    };
  }
}
