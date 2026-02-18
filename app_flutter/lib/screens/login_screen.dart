import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../services/auth_service.dart';
import 'admin_dashboard.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── Colores reutilizables ──
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
    final authService = Provider.of<AuthService>(context, listen: false);
    final session = Provider.of<SessionProvider>(context, listen: false);
    final result = await authService.login(documento, contrasena);
    if (result['success'] == true) {
      session.login(
        userName: result['nombre'],
        userRole: result['rol'],
        token: result['token'],
      );
      if (!mounted) return;
      // La navegacion interna que depende del rol
      if (result['rol'] == 'estudiante') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => StudentDashboard(userName: result['nombre']),
          ),
        );
      } else if (result['rol'] == 'profesor') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TeacherDashboard(userName: result['nombre']),
          ),
        );
      } else if (result['rol'] == 'administrador' ||
          result['rol'] == 'bibliotecario') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminDashboard(
              userName: result['nombre'],
              userRole: result['rol'],
            ),
          ),
        );
      } else {
        setState(() => _error = 'Rol no soportado');
      }
    } else {
      setState(() => _error = result['error'] ?? 'Error desconocido');
    }
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
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Icon
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

                    // Title
                    const Text(
                      '¡Bienvenido!',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accede a tu biblioteca escolar',
                      style: TextStyle(
                        color: _textColor.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Documento',
                        style: TextStyle(
                          color: _textColor.withValues(alpha: 0.8),
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
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          color: _primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contraseña',
                        style: TextStyle(
                          color: _textColor.withValues(alpha: 0.8),
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
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          letterSpacing: 2,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: _primaryColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),

                    // Error Message
                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: _textColor.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
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
