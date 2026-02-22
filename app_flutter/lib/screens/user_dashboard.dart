import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../widgets/change_password_dialog.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/books_grid.dart';

class StudentDashboard extends StatefulWidget {
  final String userName;
  final String rol;

  const StudentDashboard({
    super.key,
    required this.userName,
    required this.rol,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  static const Color backgroundColor = Color(0xFFEAE2D7);
  static const Color cardColor = Color(0xFFF3EFE7);
  static const Color primaryColor = Color(0xFF8D7B68);
  static const Color textColor = Color(0xFF4E342E);

  int _selectedIndex = 0;
  String _searchQuery = '';
  String? _selectedAuthor;
  String? _selectedCategory;

  List<dynamic> _books = [];
  List<dynamic> _loans = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadSolicitudes();
  }

  // Cargar libros
  Future<void> _loadBooks() async {
    final url = Uri.parse("http://localhost:3000/libros");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() => _books = data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al cargar libros: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    final s = date.toString();
    if (s.contains('T')) return s.split('T')[0];
    return s;
  }

  // Cargar solicitudes
  Future<void> _loadSolicitudes() async {
    // Verificar que tenemos el id del usuario antes de pedir sus solicitudes
    final session = Provider.of<SessionProvider>(context, listen: false);
    if (session.userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Usuario no identificado para cargar solicitudes"),
          ),
        );
      }
      return;
    }

    // Usar el endpoint específico para obtener las solicitudes de un usuario
    final url = Uri.parse(
      "http://localhost:3000/usuarios/${session.userId}/solicitudes",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _loans = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error al cargar solicitudes: ${response.statusCode}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  // Solicitar libro
  Future<void> _solicitarLibro(String idLibro, String titulo) async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    if (session.userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se pudo solicitar: usuario no identificado"),
          ),
        );
      }
      return;
    }

    final url = Uri.parse("http://localhost:3000/solicitudes");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_usuario": session.userId, "id_libro": idLibro}),
      );
      // Depurar en cliente: si falla mostrar el cuerpo de la respuesta
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _loans.add({
            'libro': titulo,
            'fecha': DateTime.now().toString().split(' ')[0],
            'devolucion': 'Pendiente',
            'estado': 'Pendiente',
          });
        });
        // Refrescar solicitudes desde el servidor para sincronizar con el estado real
        await _loadSolicitudes();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Solicitud enviada")));
      } else {
        String body = response.body;
        // intentar parsear mensaje del servidor
        try {
          final parsed = json.decode(response.body);
          if (parsed is Map && parsed['message'] != null)
            body = parsed['message'];
        } catch (_) {}
        print(
          'Solicitud fallo: status=${response.statusCode} body=${response.body}',
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al solicitar: $body')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  List<String> get authors => _books
      .map((b) => (b['autor'] ?? '').toString())
      .where((a) => a.isNotEmpty)
      .toSet()
      .toList();

  List<String> get categories => _books
      .map((b) => (b['area'] ?? '').toString())
      .where((c) => c.isNotEmpty)
      .toSet()
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
        title: Text(
          "Hola, ${widget.userName}",
          style: const TextStyle(color: textColor),
        ),
        actions: [_buildPopupMenu()],
      ),
      body: _selectedIndex == 0 ? _buildBooks() : _buildLoans(),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: cardColor,
      child: Column(
        children: [
          const SizedBox(height: 60),
          _menuItem(Icons.menu_book, "Libros", 0),
          _menuItem(Icons.assignment, "Solicitudes", 1),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String text, int index) {
    final selected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? primaryColor.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(text, style: const TextStyle(color: textColor)),
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }

  PopupMenuButton<String> _buildPopupMenu() {
    return PopupMenuButton<String>(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        if (value == "logout") {
          _logout();
          return;
        }
        if (value == "change_pass") {
          showDialog(
            context: context,
            builder: (_) => const ChangePasswordDialog(),
          );
          return;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: "change_pass",
          child: Text("Cambiar contraseña", style: TextStyle(color: textColor)),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: "logout",
          child: Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildBooks() {
    final filtered = _books.where((b) {
      final titulo = (b['titulo'] ?? '').toString().toLowerCase();
      final autor = (b['autor'] ?? '').toString();
      final area = (b['area'] ?? '').toString();
      final q = _searchQuery.toLowerCase();
      return titulo.contains(q) &&
          (_selectedAuthor == null || autor == _selectedAuthor) &&
          (_selectedCategory == null || area == _selectedCategory);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: "Buscar libro...",
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedAuthor,
                  hint: const Text("Escritor"),
                  items: authors
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedAuthor = v),
                  dropdownColor: cardColor,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text("Tipo"),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  dropdownColor: cardColor,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildBooksGrid(filtered)),
        ],
      ),
    );
  }

  Widget _buildBooksGrid(List<dynamic> books) {
    final List<Map<String, String>> items = books.map<Map<String, String>>((b) {
      return {
        'id_libro': (b['id_libro'] ?? b['id'] ?? '').toString(),
        'titulo': (b['titulo'] ?? '').toString(),
        'autor': (b['autor'] ?? '').toString(),
        'area': (b['area'] ?? '').toString(),
      };
    }).toList();

    return BooksGrid(
      books: items,
      onRequest: (id, title) => _solicitarLibro(id, title),
    );
  }

  Widget _buildLoans() {
    if (_loans.isEmpty)
      return const Center(child: Text("No hay solicitudes registradas"));
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: _loans.length,
        itemBuilder: (context, index) {
          final loan = _loans[index];
          final titulo = loan['titulo'] ?? loan['libro'] ?? '';
          final fecha = loan['fecha'] ?? loan['fecha_solicitud'] ?? '';
          final devolucion =
              loan['devolucion'] ?? loan['fecha_devolucion'] ?? '';
          final estado = loan['estado'] ?? '';

          final estadoLower = (estado ?? '').toString().toLowerCase();
          Color pillBg;
          Color pillText;
          if (estadoLower == 'aprobada' || estadoLower == 'aprobado') {
            pillBg = const Color(0xFFE6F4EA);
            pillText = const Color(0xFF2E7D32);
          } else if (estadoLower == 'rechazada' || estadoLower == 'rechazado') {
            pillBg = const Color(0xFFFDECEC);
            pillText = const Color(0xFFC62828);
          } else {
            pillBg = const Color(0xFFF8F0E6);
            pillText = const Color(0xFF8D6E63);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        estado ?? 'Pendiente',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: pillText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Fecha solicitud: ${_formatDate(fecha)}",
                  style: const TextStyle(color: Colors.black54),
                ),
                if (devolucion.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text("Fecha devolución: ${_formatDate(devolucion)}"),
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Estado: ${estado ?? ''}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
