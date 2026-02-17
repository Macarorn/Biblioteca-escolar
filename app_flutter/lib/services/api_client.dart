import 'package:http/http.dart' as http;

/// Cliente HTTP base para comunicarse con la API REST del backend.
/// Centraliza la URL base y agrega automáticamente el token JWT a cada petición.
class ApiClient {
  /// URL base de la API (cambiar al desplegar).
  static const String baseUrl = 'http://localhost:3000/api';

  String? _token;

  /// Guarda el token JWT recibido tras el login.
  void setToken(String token) => _token = token;

  /// Elimina el token (al cerrar sesión).
  void clearToken() => _token = null;
  String? get token => _token;

  /// Headers comunes: JSON + Authorization si hay token.
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// Petición GET.
  Future<http.Response> get(String path) =>
      http.get(Uri.parse('$baseUrl$path'), headers: _headers);

  /// Petición POST (envía body en JSON).
  Future<http.Response> post(String path, {Object? body}) =>
      http.post(Uri.parse('$baseUrl$path'), headers: _headers, body: body);

  /// Petición PUT (actualización).
  Future<http.Response> put(String path, {Object? body}) =>
      http.put(Uri.parse('$baseUrl$path'), headers: _headers, body: body);

  /// Petición DELETE.
  Future<http.Response> delete(String path) =>
      http.delete(Uri.parse('$baseUrl$path'), headers: _headers);
}
