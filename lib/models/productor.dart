class Productor {
  final int? id;
  final String nombre;
  final String apellidos;
  final String comunidad;
  final String municipio;
  final String? telefono;
  final String? correo;
  final String? descripcion;
  final int mostrarNombre;
  final int mostrarComunidad;
  final int mostrarContacto;
  final String fechaRegistro;

  Productor({
    this.id,
    required this.nombre,
    required this.apellidos,
    required this.comunidad,
    required this.municipio,
    this.telefono,
    this.correo,
    this.descripcion,
    this.mostrarNombre = 1,
    this.mostrarComunidad = 1,
    this.mostrarContacto = 0,
    required this.fechaRegistro,
  });

  factory Productor.fromMap(Map<String, dynamic> map) {
    return Productor(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      apellidos: map['apellidos'] as String,
      comunidad: map['comunidad'] as String,
      municipio: map['municipio'] as String,
      telefono: map['telefono'] as String?,
      correo: map['correo'] as String?,
      descripcion: map['descripcion'] as String?,
      mostrarNombre: map['mostrar_nombre'] as int,
      mostrarComunidad: map['mostrar_comunidad'] as int,
      mostrarContacto: map['mostrar_contacto'] as int,
      fechaRegistro: map['fecha_registro'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'comunidad': comunidad,
      'municipio': municipio,
      'telefono': telefono,
      'correo': correo,
      'descripcion': descripcion,
      'mostrar_nombre': mostrarNombre,
      'mostrar_comunidad': mostrarComunidad,
      'mostrar_contacto': mostrarContacto,
      'fecha_registro': fechaRegistro,
    };
  }
}
