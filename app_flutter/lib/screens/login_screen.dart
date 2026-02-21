import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import '../providers/session_provider.dart';
//import '../services/auth_service.dart';
import 'student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _backgroundColor = Color(0xFFEAE2D7);
  static const _cardColor = Color(0xFFF3EFE7);
  static const _primaryColor = Color(0xFF8D7B68);
  static const _textColor = Color(0xFF4E342E);
  static const _inputFillColor = Color(0xFFFAF9F6);
  static const _accentColor = Color(0xFFD7CCC8);

  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  bool _obscurePassword = true;
  String _error = '';

  Future<void> _handleSubmit() async {
  setState(() => _error = '');

  final documento = _documentoController.text.trim();
  final contrasena = _contrasenaController.text.trim();

  if (documento.isEmpty || contrasena.isEmpty) {
    setState(() => _error = 'Por favor ingresa tus credenciales');
    return;
  }

  // Contraseña fija para ambos
  if (contrasena != "1234") {
    setState(() => _error = 'Contraseña incorrecta');
    return;
  }

  String rol;
  String nombre;

  if (documento.startsWith("3")) {
    rol = "profesor";
    nombre = "Profesor $documento";
  } else if (documento.startsWith("4")) {
    rol = "estudiante";
    nombre = "Estudiante $documento";
  } else {
    setState(() => _error = 'Documento no válido');
    return;
  }

  if (!mounted) return;

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => Dashboard(
        userName: nombre,
        rol: rol,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 400,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 48,
                ),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _accentColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: _textColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      '¡Bienvenido!',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'Accede a tu biblioteca escolar',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Documento',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _documentoController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _inputFillColor,
                        hintText: 'Ingresa tu identificación',
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          color: _primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Contraseña',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _contrasenaController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _inputFillColor,
                        hintText: '••••••••',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: _primaryColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Ingresar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}