/// Modelo que representa un usuario del sistema.
/// Roles posibles: estudiante, profesor, bibliotecario, administrador.
class Usuario {
  final int? id;
  final String nombre; // Nombre completo
  final String documento; // Número de documento (también sirve como login)
  final String email;
  final String rol; // estudiante | profesor | bibliotecario | administrador

  Usuario({
    this.id,
    required this.nombre,
    required this.documento,
    required this.email,
    required this.rol,
  });

  /// Crea un Usuario a partir del JSON que devuelve la API.
  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'],
    nombre: json['nombre'],
    documento: json['documento'],
    email: json['email'],
    rol: json['rol'],
  );

  /// Convierte el Usuario a JSON para enviarlo a la API.
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'documento': documento,
    'email': email,
    'rol': rol,
  };
}
