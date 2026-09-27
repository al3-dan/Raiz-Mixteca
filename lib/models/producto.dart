class Producto {
  final int? id;
  final int productorId;
  final String nombre;
  final String tipo;
  final String? descripcion;

  Producto({
    this.id,
    required this.productorId,
    required this.nombre,
    required this.tipo,
    this.descripcion,
  });

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as int?,
      productorId: map['productor_id'] as int,
      nombre: map['nombre'] as String,
      tipo: map['tipo'] as String,
      descripcion: map['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productor_id': productorId,
      'nombre': nombre,
      'tipo': tipo,
      'descripcion': descripcion,
    };
  }
}
