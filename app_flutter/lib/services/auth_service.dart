import 'api_client.dart';

/// Servicio de autenticación.
/// Se encarga del login y logout del usuario.
class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  /// Inicia sesión con documento y contraseña.
  /// Retorna un mapa con { success, nombre, rol, token } o { success: false, error }.
  /// Actualmente usa datos simulados; descomentar la llamada real cuando la API esté lista.
  Future<Map<String, dynamic>> login(
    String documento,
    String contrasena,
  ) async {
    // ── Llamada real (descomentar cuando la API esté lista) ──
    // final response = await _api.post('/auth/login', body: jsonEncode({
    //   'documento': documento,
    //   'contrasena': contrasena,
    // }));
    // if (response.statusCode == 200) {
    //   final data = jsonDecode(response.body);
    //   _api.setToken(data['token']);
    //   return data;
    // }
    // throw Exception('Login fallido: ${response.statusCode}');

    // ── Simulación para desarrollo ──
    await Future.delayed(const Duration(milliseconds: 300));

    final users = {
      '1001': {
        'nombre': 'Juan Pérez',
        'rol': 'estudiante',
        'token': 'tok_est_001',
      },
      '2001': {
        'nombre': 'Prof. García',
        'rol': 'profesor',
        'token': 'tok_prof_001',
      },
      '3001': {
        'nombre': 'Carlos Ramírez',
        'rol': 'bibliotecario',
        'token': 'tok_bib_001',
      },
      '4001': {
        'nombre': 'Ana Martínez',
        'rol': 'administrador',
        'token': 'tok_adm_001',
      },
    };

    if (users.containsKey(documento)) {
      final user = users[documento]!;
      _api.setToken(user['token']!);
      return {'success': true, ...user};
    }

    return {'success': false, 'error': 'Credenciales incorrectas'};
  }

  /// Cierra sesión eliminando el token.
  void logout() => _api.clearToken();
}
