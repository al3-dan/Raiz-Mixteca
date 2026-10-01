class Mensaje {
  final int? id;
  final int remitenteId;
  final int destinatarioId;
  final String? asunto;
  final String contenido;
  final String fecha;
  final int leido;

  Mensaje({
    this.id,
    required this.remitenteId,
    required this.destinatarioId,
    this.asunto,
    required this.contenido,
    required this.fecha,
    this.leido = 0,
  });

  factory Mensaje.fromMap(Map<String, dynamic> map) {
    return Mensaje(
      id: map['id'] as int?,
      remitenteId: map['remitente_id'] as int,
      destinatarioId: map['destinatario_id'] as int,
      asunto: map['asunto'] as String?,
      contenido: map['contenido'] as String,
      fecha: map['fecha'] as String,
      leido: map['leido'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remitente_id': remitenteId,
      'destinatario_id': destinatarioId,
      'asunto': asunto,
      'contenido': contenido,
      'fecha': fecha,
      'leido': leido,
    };
  }

  Mensaje copyWith({
    int? id,
    int? remitenteId,
    int? destinatarioId,
    String? asunto,
    String? contenido,
    String? fecha,
    int? leido,
  }) {
    return Mensaje(
      id: id ?? this.id,
      remitenteId: remitenteId ?? this.remitenteId,
      destinatarioId: destinatarioId ?? this.destinatarioId,
      asunto: asunto ?? this.asunto,
      contenido: contenido ?? this.contenido,
      fecha: fecha ?? this.fecha,
      leido: leido ?? this.leido,
    );
  }
}
