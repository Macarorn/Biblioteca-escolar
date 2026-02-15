import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Biblioteca',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: LoginScreen(
        onLogin: (documento, contrasena) {
          // Simulación de login - Aquí conectarías con tu lógica real
          print('Intento de acceso: $documento');
          // Retornamos true para permitir el acceso en esta prueba
          // Puedes poner validaciones específicas aquí (ej: if documento == '1001'...)
          return true;
        },
      ),
    );
  }
}
