import 'api_client.dart';

/// Servicio para todas las operaciones del catálogo:
/// libros, ejemplares, solicitudes, préstamos y devoluciones.
/// Cada método tiene la llamada real comentada y retorna datos vacíos por ahora.
class LibrosService {
  // ignore: unused_field
  final ApiClient api;

  LibrosService(this.api);

  /// Obtiene la lista completa de libros.
  /// GET /libros
  Future<List<Map<String, dynamic>>> getLibros() async {
    // final response = await _api.get('/libros');
    // return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    return [];
  }

  /// Obtiene los ejemplares de un libro específico.
  /// GET /libros/:id/ejemplares
  Future<List<Map<String, dynamic>>> getEjemplares(int libroId) async {
    // final response = await _api.get('/libros/$libroId/ejemplares');
    // return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    return [];
  }

  /// Crea una solicitud de préstamo (estudiante/profesor).
  /// POST /solicitudes
  Future<Map<String, dynamic>> crearSolicitud({
    required int libroId,
    required int usuarioId,
  }) async {
    // final response = await _api.post('/solicitudes', body: jsonEncode({
    //   'libro_id': libroId,
    //   'usuario_id': usuarioId,
    // }));
    // return jsonDecode(response.body);
    return {'success': true};
  }

  /// Obtiene las solicitudes con estado "pendiente".
  /// GET /solicitudes?estado=pendiente
  Future<List<Map<String, dynamic>>> getSolicitudesPendientes() async {
    // final response = await _api.get('/solicitudes?estado=pendiente');
    // return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    return [];
  }

  /// Aprueba una solicitud y crea el préstamo correspondiente.
  /// PUT /solicitudes/:id/aprobar
  Future<Map<String, dynamic>> aprobarSolicitud(int solicitudId) async {
    // final response = await _api.put('/solicitudes/$solicitudId/aprobar');
    // return jsonDecode(response.body);
    return {'success': true};
  }

  /// Rechaza una solicitud.
  /// PUT /solicitudes/:id/rechazar
  Future<Map<String, dynamic>> rechazarSolicitud(int solicitudId) async {
    // final response = await _api.put('/solicitudes/$solicitudId/rechazar');
    // return jsonDecode(response.body);
    return {'success': true};
  }

  /// Registra la devolución de un préstamo con su condición.
  /// POST /devoluciones
  Future<Map<String, dynamic>> registrarDevolucion({
    required int prestamoId,
    required String condicion,
    String? observaciones,
  }) async {
    // final response = await _api.post('/devoluciones', body: jsonEncode({
    //   'prestamo_id': prestamoId,
    //   'condicion': condicion,
    //   'observaciones': observaciones,
    // }));
    // return jsonDecode(response.body);
    return {'success': true};
  }
}
