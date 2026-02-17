import 'package:flutter/material.dart';

/// Provider que mantiene el estado de la sesión del usuario autenticado.
/// Se usa con el paquete `provider` para que cualquier widget pueda
/// consultar quién está logueado y qué rol tiene.
class SessionProvider extends ChangeNotifier {
  String _userName = '';
  String _userRole = '';
  String _token = '';
  bool _isAuthenticated = false;

  // ── Getters ──
  String get userName => _userName;
  String get userRole => _userRole;
  String get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  // ── Atajos de rol ──
  bool get isAdmin => _userRole == 'administrador';
  bool get isBibliotecario => _userRole == 'bibliotecario';
  bool get isGestor =>
      isAdmin || isBibliotecario; // Puede gestionar libros/préstamos
  bool get isEstudiante => _userRole == 'estudiante';
  bool get isProfesor => _userRole == 'profesor';

  /// Guarda los datos de sesión tras un login exitoso y notifica a los listeners.
  void login({
    required String userName,
    required String userRole,
    required String token,
  }) {
    _userName = userName;
    _userRole = userRole;
    _token = token;
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Limpia la sesión al cerrar sesión y notifica a los listeners.
  void logout() {
    _userName = '';
    _userRole = '';
    _token = '';
    _isAuthenticated = false;
    notifyListeners();
  }
}
