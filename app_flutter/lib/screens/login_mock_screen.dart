import 'package:flutter/material.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';


class LoginMockScreen extends StatefulWidget {
  const LoginMockScreen({super.key});

  @override
  State<LoginMockScreen> createState() => _LoginMockScreenState();
}

class _LoginMockScreenState extends State<LoginMockScreen> {
  final TextEditingController _userController = TextEditingController();
  String _error = '';

  void _login() {
    final user = _userController.text.trim();

    if (user.isEmpty) {
      setState(() => _error = 'Ingresa un usuario');
      return;
    }

    // 🔹 ESTUDIANTE
    if (user == '111') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentDashboard(
            userName: 'Estudiante Demo',
          ),
        ),
      );
      return;
    }

    // 🔹 PROFESOR
    if (user == '222') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TeacherDashboard(
            userName: 'Profesor Demo',
          ),
        ),
      );
      return;
    }

    setState(() => _error = 'Usuario no válido');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE2D7),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EFE7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book,
                  size: 50, color: Color(0xFF4E342E)),
              const SizedBox(height: 20),
              const Text(
                'Login de Prueba',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E342E),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  hintText: '111 (Estudiante) | 222 (Profesor)',
                  filled: true,
                  fillColor: Colors.white,
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
                  style: const TextStyle(color: Colors.red),
                )
              ],
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D7B68),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}