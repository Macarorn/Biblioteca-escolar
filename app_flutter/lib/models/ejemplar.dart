/// Modelo que representa un ejemplar físico de un libro.
/// Cada libro puede tener varios ejemplares con códigos únicos (ej: CAS-001).
class Ejemplar {
  final int? id;
  final int libroId; // ID del libro al que pertenece
  final String codigo; // Código único del ejemplar (ej: CAS-001)
  String condicion; // excelente | bueno | regular | malo
  String disponibilidad; // disponible | prestado

  Ejemplar({
    this.id,
    required this.libroId,
    required this.codigo,
    required this.condicion,
    required this.disponibilidad,
  });

  /// Crea un Ejemplar desde el JSON de la API.
  factory Ejemplar.fromJson(Map<String, dynamic> json) => Ejemplar(
    id: json['id'],
    libroId: json['libro_id'],
    codigo: json['codigo'],
    condicion: json['condicion'],
    disponibilidad: json['disponibilidad'],
  );

  /// Convierte el Ejemplar a JSON para enviarlo a la API.
  Map<String, dynamic> toJson() => {
    'id': id,
    'libro_id': libroId,
    'codigo': codigo,
    'condicion': condicion,
    'disponibilidad': disponibilidad,
  };
}
