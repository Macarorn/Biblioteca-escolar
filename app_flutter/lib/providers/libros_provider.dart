import 'package:flutter/material.dart';

/// Provider que gestiona el estado reactivo de libros y solicitudes.
/// Los widgets escuchan cambios con Consumer o context.watch.
class LibrosProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _libros = [];
  final List<Map<String, dynamic>> _solicitudes = [];

  /// Lista inmutable de libros (para que no se modifique desde fuera).
  List<Map<String, dynamic>> get libros => List.unmodifiable(_libros);

  /// Lista inmutable de solicitudes.
  List<Map<String, dynamic>> get solicitudes => List.unmodifiable(_solicitudes);

  /// Filtra solo las solicitudes pendientes.
  List<Map<String, dynamic>> get solicitudesPendientes =>
      _solicitudes.where((s) => s['estado'] == 'pendiente').toList();

  /// Reemplaza toda la lista de libros (tras cargar de la API).
  void setLibros(List<Map<String, dynamic>> libros) {
    _libros
      ..clear()
      ..addAll(libros);
    notifyListeners();
  }

  /// Agrega una solicitud nueva.
  void addSolicitud(Map<String, dynamic> solicitud) {
    _solicitudes.add(solicitud);
    notifyListeners();
  }

  /// Actualiza una solicitud existente por índice.
  void updateSolicitud(int index, Map<String, dynamic> solicitud) {
    if (index >= 0 && index < _solicitudes.length) {
      _solicitudes[index] = solicitud;
      notifyListeners();
    }
  }

  /// Elimina una solicitud por índice.
  void removeSolicitud(int index) {
    if (index >= 0 && index < _solicitudes.length) {
      _solicitudes.removeAt(index);
      notifyListeners();
    }
  }
}
