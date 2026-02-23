import 'dart:convert';
import 'api_client.dart';

/// Servicio de autenticación conectado al backend.
class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  /// Inicia sesión con documento y contraseña.
  /// Retorna un mapa con { success, nombre, rol, token } o { success: false, error }.
  Future<Map<String, dynamic>> login(
    String documento,
    String contrasena,
  ) async {
    final response = await _api.post(
      '/auth/login',
      body: jsonEncode({'documento': documento, 'contrasena': contrasena}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _api.setToken(data['token']);
      return {
        'success': true,
        'id': data['usuario']['id'],
        'nombre': data['usuario']['nombre'],
        'rol': data['usuario']['tipo_usuario'],
        'token': data['token'],
      };
    } else {
      String errorMsg = 'Credenciales incorrectas';
      try {
        final data = jsonDecode(response.body);
        errorMsg = data['message'] ?? errorMsg;
      } catch (_) {}
      return {'success': false, 'error': errorMsg};
    }
  }

  /// Cierra sesión eliminando el token.
  void logout() => _api.clearToken();
}
