/// Modelo que representa una solicitud de préstamo.
/// Flujo: pendiente → aprobada (se crea un Préstamo) o rechazada.
class Solicitud {
  final int? id;
  final int usuarioId; // Quién solicita
  final int libroId; // Qué libro solicita
  final int? ejemplarId; // Ejemplar específico (opcional)
  String estado; // pendiente | aprobada | rechazada
  final DateTime fechaSolicitud;

  // Campos extra que vienen del JOIN en la API (solo lectura)
  final String? nombreUsuario;
  final String? tituloLibro;
  final String? codigoEjemplar;

  Solicitud({
    this.id,
    required this.usuarioId,
    required this.libroId,
    this.ejemplarId,
    required this.estado,
    required this.fechaSolicitud,
    this.nombreUsuario,
    this.tituloLibro,
    this.codigoEjemplar,
  });

  /// Crea una Solicitud desde el JSON de la API.
  factory Solicitud.fromJson(Map<String, dynamic> json) => Solicitud(
    id: json['id'],
    usuarioId: json['usuario_id'],
    libroId: json['libro_id'],
    ejemplarId: json['ejemplar_id'],
    estado: json['estado'],
    fechaSolicitud: DateTime.parse(json['fecha_solicitud']),
    nombreUsuario: json['nombre_usuario'],
    tituloLibro: json['titulo_libro'],
    codigoEjemplar: json['codigo_ejemplar'],
  );

  /// Convierte la Solicitud a JSON para enviarlo a la API.
  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'libro_id': libroId,
    'ejemplar_id': ejemplarId,
    'estado': estado,
    'fecha_solicitud': fechaSolicitud.toIso8601String(),
  };
}
