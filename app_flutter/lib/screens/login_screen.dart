import 'package:flutter/material.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final bool Function(String documento, String contrasena) onLogin;

  const LoginScreen({super.key, required this.onLogin});

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

  final _documentoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _obscurePassword = true;

  String _error = '';

  void _handleSubmit() {
    setState(() => _error = '');

    final documento = _documentoController.text.trim();
    final contrasena = _contrasenaController.text.trim();

    if (documento.isEmpty || contrasena.isEmpty) {
      if (mounted) {
        setState(() => _error = 'Por favor complete todos los campos');
      }
      return;
    }

    final success = widget.onLogin(documento, contrasena);

    if (success) {
      if (documento.startsWith('1')) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                const StudentDashboard(userName: 'Juan Pérez'),
          ),
        );
      } else if (documento.startsWith('2')) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                const TeacherDashboard(userName: 'Prof. García'),
          ),
        );
      } else if (documento.startsWith('3')) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AdminDashboard(
              userName: 'Carlos Ramírez',
              userRole: 'bibliotecario',
            ),
          ),
        );
      } else if (documento.startsWith('4')) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AdminDashboard(
              userName: 'Ana Martínez',
              userRole: 'administrador',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento no reconocido')),
        );
      }
    } else {
      if (mounted) {
        setState(() => _error = 'Documento o contraseña incorrectos');
      }
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
