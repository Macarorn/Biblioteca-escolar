/// Modelo que representa un libro en el catálogo.
/// Un libro puede tener varios ejemplares físicos (ver Ejemplar).
class Libro {
  final int? id;
  final String titulo;
  final String autor;
  final String categoria; // Ej: Literatura, Ciencias, Historia...
  int disponibles; // Ejemplares disponibles para préstamo
  int total; // Total de ejemplares registrados

  Libro({
    this.id,
    required this.titulo,
    required this.autor,
    required this.categoria,
    required this.disponibles,
    required this.total,
  });

  /// Crea un Libro desde el JSON de la API.
  factory Libro.fromJson(Map<String, dynamic> json) => Libro(
    id: json['id'],
    titulo: json['titulo'],
    autor: json['autor'],
    categoria: json['categoria'],
    disponibles: json['disponibles'] ?? 0,
    total: json['total'] ?? 0,
  );

  /// Convierte el Libro a JSON para enviarlo a la API.
  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'autor': autor,
    'categoria': categoria,
    'disponibles': disponibles,
    'total': total,
  };
}
