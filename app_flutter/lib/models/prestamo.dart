/// Modelo que representa un préstamo activo o devuelto.
/// Se crea automáticamente cuando una Solicitud es aprobada.
/// Flujo: activo → devuelto (se registra condición y observaciones).
class Prestamo {
  final int? id;
  final int solicitudId; // Solicitud que originó este préstamo
  final int ejemplarId; // Ejemplar prestado
  final int usuarioId; // Usuario que tiene el libro
  String estado; // activo | devuelto
  final DateTime fechaPrestamo;
  final DateTime fechaDevolucionEstimada;
  DateTime? fechaDevolucionReal; // Se llena al devolver
  String? condicionDevolucion; // Estado del libro al devolverse
  String? observaciones; // Notas del bibliotecario

  // Campos extra del JOIN en la API (solo lectura)
  final String? nombreUsuario;
  final String? tituloLibro;
  final String? codigoEjemplar;

  Prestamo({
    this.id,
    required this.solicitudId,
    required this.ejemplarId,
    required this.usuarioId,
    required this.estado,
    required this.fechaPrestamo,
    required this.fechaDevolucionEstimada,
    this.fechaDevolucionReal,
    this.condicionDevolucion,
    this.observaciones,
    this.nombreUsuario,
    this.tituloLibro,
    this.codigoEjemplar,
  });

  /// Crea un Prestamo desde el JSON de la API.
  factory Prestamo.fromJson(Map<String, dynamic> json) => Prestamo(
    id: json['id'],
    solicitudId: json['solicitud_id'],
    ejemplarId: json['ejemplar_id'],
    usuarioId: json['usuario_id'],
    estado: json['estado'],
    fechaPrestamo: DateTime.parse(json['fecha_prestamo']),
    fechaDevolucionEstimada: DateTime.parse(json['fecha_devolucion_estimada']),
    fechaDevolucionReal: json['fecha_devolucion_real'] != null
        ? DateTime.parse(json['fecha_devolucion_real'])
        : null,
    condicionDevolucion: json['condicion_devolucion'],
    observaciones: json['observaciones'],
    nombreUsuario: json['nombre_usuario'],
    tituloLibro: json['titulo_libro'],
    codigoEjemplar: json['codigo_ejemplar'],
  );

  /// Convierte el Prestamo a JSON para enviarlo a la API.
  Map<String, dynamic> toJson() => {
    'id': id,
    'solicitud_id': solicitudId,
    'ejemplar_id': ejemplarId,
    'usuario_id': usuarioId,
    'estado': estado,
    'fecha_prestamo': fechaPrestamo.toIso8601String(),
    'fecha_devolucion_estimada': fechaDevolucionEstimada.toIso8601String(),
    'fecha_devolucion_real': fechaDevolucionReal?.toIso8601String(),
    'condicion_devolucion': condicionDevolucion,
    'observaciones': observaciones,
  };
}
