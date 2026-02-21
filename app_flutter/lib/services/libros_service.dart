import 'dart:convert';
import 'api_client.dart';

/// Servicio para todas las operaciones del catálogo:
/// libros, ejemplares, préstamos, devoluciones y solicitudes.
class LibrosService {
  final ApiClient api;

  LibrosService(this.api);

  // ── Libros ──

  Future<List<Map<String, dynamic>>> getLibros({
    String? titulo,
    String? autor,
    String? area,
  }) async {
    String path = '/libros';
    final params = <String>[];
    if (titulo != null && titulo.isNotEmpty) params.add('titulo=$titulo');
    if (autor != null && autor.isNotEmpty) params.add('autor=$autor');
    if (area != null && area.isNotEmpty) params.add('area=$area');
    if (params.isNotEmpty) path += '?${params.join('&')}';

    final response = await api.get(path);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Error al obtener libros: ${response.body}');
  }

  Future<Map<String, dynamic>> createLibro(Map<String, dynamic> data) async {
    final response = await api.post('/libros', body: jsonEncode(data));
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Error al crear libro: ${response.body}');
  }

  Future<void> updateLibro(int id, Map<String, dynamic> data) async {
    final response = await api.put('/libros/$id', body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar libro: ${response.body}');
    }
  }

  Future<void> deleteLibro(int id) async {
    final response = await api.delete('/libros/$id');
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar libro: ${response.body}');
    }
  }

  // ── Ejemplares ──

  Future<List<Map<String, dynamic>>> getEjemplares(int libroId) async {
    final response = await api.get('/libros/$libroId/ejemplares');
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Error al obtener ejemplares: ${response.body}');
  }

  Future<Map<String, dynamic>> getDisponibilidad(int libroId) async {
    final response = await api.get('/libros/$libroId/disponibilidad');
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Error al obtener disponibilidad: ${response.body}');
  }

  Future<Map<String, dynamic>> createEjemplar(Map<String, dynamic> data) async {
    final response = await api.post('/ejemplares', body: jsonEncode(data));
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Error al crear ejemplar: ${response.body}');
  }

  Future<void> updateEjemplar(int id, Map<String, dynamic> data) async {
    final response = await api.put('/ejemplares/$id', body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar ejemplar: ${response.body}');
    }
  }

  Future<void> deleteEjemplar(int id) async {
    final response = await api.delete('/ejemplares/$id');
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar ejemplar: ${response.body}');
    }
  }

  // ── Préstamos ──

  Future<List<Map<String, dynamic>>> getPrestamos() async {
    final response = await api.get('/prestamos');
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Error al obtener préstamos: ${response.body}');
  }

  Future<Map<String, dynamic>> createPrestamo(Map<String, dynamic> data) async {
    final response = await api.post('/prestamos', body: jsonEncode(data));
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Error al crear préstamo: ${response.body}');
  }

  // ── Devoluciones ──

  Future<Map<String, dynamic>> devolverPrestamo(
    int prestamoId, {
    String? observaciones,
  }) async {
    final response = await api.post(
      '/prestamos/$prestamoId/devolver',
      body: jsonEncode({'observaciones': observaciones ?? ''}),
    );
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Error al devolver préstamo: ${response.body}');
  }

  // ── Solicitudes ──

  Future<List<Map<String, dynamic>>> getSolicitudes({String? estado}) async {
    String path = '/solicitudes';
    if (estado != null && estado.isNotEmpty) path += '?estado=$estado';

    final response = await api.get(path);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Error al obtener solicitudes: ${response.body}');
  }

  Future<void> updateEstadoSolicitud(int id, String estado) async {
    final response = await api.put(
      '/solicitudes/$id/estado',
      body: jsonEncode({'estado': estado}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar solicitud: ${response.body}');
    }
  }

  // ── Usuarios ──

  Future<List<Map<String, dynamic>>> getUsuarios() async {
    final response = await api.get('/usuarios');
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Error al obtener usuarios: ${response.body}');
  }

  Future<Map<String, dynamic>> createUsuario(Map<String, dynamic> data) async {
    final response = await api.post('/usuarios', body: jsonEncode(data));
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Error al crear usuario: ${response.body}');
  }

  Future<void> updateUsuario(int id, Map<String, dynamic> data) async {
    final response = await api.put('/usuarios/$id', body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar usuario: ${response.body}');
    }
  }

  Future<void> deleteUsuario(int id) async {
    final response = await api.delete('/usuarios/$id');
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar usuario: ${response.body}');
    }
  }
}
