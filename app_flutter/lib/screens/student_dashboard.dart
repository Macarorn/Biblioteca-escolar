import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  final String userName;
  final String rol; 
  final String userId; // 👈 Nuevo: ID del usuario dinámico

  const Dashboard({
    super.key,
    required this.userName,
    required this.rol,
    required this.userId,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static const Color backgroundColor = Color(0xFFEAE2D7);
  static const Color cardColor = Colors.white;
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
    final url = Uri.parse("http://localhost/biblioteca_api/libros.php");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() => _books = data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar libros: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  // Cargar solicitudes
  Future<void> _loadSolicitudes() async {
    final url = Uri.parse("http://localhost/biblioteca_api/solicitudes.php");
    try {
      final response = await http.post(
        url,
        body: {"id_usuario": widget.userId},
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _loans = data;
          _selectedIndex = 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar solicitudes: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  // Solicitar libro
  Future<void> _solicitarLibro(String idLibro, String titulo) async {
    final url = Uri.parse("http://localhost/biblioteca_api/solicitar.php");
    try {
      final response = await http.post(
        url,
        body: {"id_usuario": widget.userId, "id_libro": idLibro},
      );
      if (response.statusCode == 200) {
        setState(() {
          _loans.add({
            'libro': titulo,
            'fecha': DateTime.now().toString().split(' ')[0],
            'devolucion': 'Pendiente',
            'estado': 'Pendiente',
          });
          _selectedIndex = 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Solicitud enviada")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al solicitar")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
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
        title: Text("Hola, ${widget.userName}", style: const TextStyle(color: textColor)),
        actions: [_buildPopupMenu()],
      ),
      body: _selectedIndex == 0 ? _buildBooks() : _buildLoans(),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
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
      onSelected: (value) {
        if (value == "logout") _logout();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: "profile", child: Text("Mi perfil")),
        PopupMenuItem(value: "settings", child: Text("Configuración")),
        PopupMenuDivider(),
        PopupMenuItem(value: "logout", child: Text("Cerrar sesión", style: TextStyle(color: Colors.red))),
      ],
    );
  }

  Widget _buildBooks() {
    final filtered = _books.where((b) {
      final titulo = (b['titulo'] ?? '').toString().toLowerCase();
      final autor = (b['autor'] ?? '').toString();
      final area = (b['area'] ?? '').toString();
      final q = _searchQuery.toLowerCase();
      return titulo.contains(q) && (_selectedAuthor == null || autor == _selectedAuthor) && (_selectedCategory == null || area == _selectedCategory);
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
              fillColor: Colors.white,
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
                  items: authors.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                  onChanged: (v) => setState(() => _selectedAuthor = v),
                  decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text("Tipo"),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
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
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3EFE7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            children: [
              Container(
                height: 130,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  book['titulo'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book['titulo'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
                      const SizedBox(height: 4),
                      Text(book['autor'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryColor)),
                            child: Text(book['area'] ?? '', style: const TextStyle(fontSize: 10, color: primaryColor)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(horizontal: 10)),
                            onPressed: () => _solicitarLibro(book['id_libro'].toString(), book['titulo'].toString()),
                            child: const Text("Solicitar", style: TextStyle(fontSize: 10)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoans() {
    if (_loans.isEmpty) return const Center(child: Text("No hay solicitudes registradas"));
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: _loans.length,
        itemBuilder: (context, index) {
          final loan = _loans[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loan['libro'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("Fecha: ${loan['fecha'] ?? ''}"),
                Text("Estado: ${loan['estado'] ?? ''}"),
              ],
            ),
          );
        },
      ),
    );
  }
}