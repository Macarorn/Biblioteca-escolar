import 'package:flutter/material.dart';
import 'login_mock_screen.dart';

class StudentDashboard extends StatefulWidget {
  final String userName;

  const StudentDashboard({super.key, required this.userName});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  static const Color backgroundColor = Color(0xFFEAE2D7);
  static const Color cardColor = Colors.white;
  static const Color primaryColor = Color(0xFF8D7B68);
  static const Color textColor = Color(0xFF4E342E);

  int _selectedIndex = 0;
  int _currentPage = 0;
  final int _itemsPerPage = 6;

  String _searchQuery = '';
  String? _selectedAuthor;
  String? _selectedCategory;

  final List<Map<String, dynamic>> _books = [
    {'titulo': 'Cien años de soledad', 'autor': 'Gabriel García Márquez', 'area': 'Literatura'},
    {'titulo': 'El principito', 'autor': 'Antoine de Saint-Exupéry', 'area': 'Infantil'},
    {'titulo': 'Don Quijote de la Mancha', 'autor': 'Miguel de Cervantes', 'area': 'Clásicos'},
    {'titulo': 'Harry Potter', 'autor': 'J.K. Rowling', 'area': 'Fantasía'},
    {'titulo': 'Clean Code', 'autor': 'Robert C. Martin', 'area': 'Programación'},
    {'titulo': 'Flutter en Acción', 'autor': 'Eric Windmill', 'area': 'Programación'},
    {'titulo': 'Matemáticas Básicas', 'autor': 'Juan Pérez', 'area': 'Matemáticas'},
    {'titulo': 'Biología Moderna', 'autor': 'Laura Gómez', 'area': 'Ciencias'},
  ];

  final List<Map<String, dynamic>> _loans = [
    {
      'libro': 'Cien años de soledad',
      'fecha': '2024-02-01',
      'devolucion': '2024-02-10',
      'estado': 'Activo'
    },
    {
      'libro': 'Clean Code',
      'fecha': '2024-01-10',
      'devolucion': '2024-01-20',
      'estado': 'Devuelto'
    },
  ];

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginMockScreen()),
      (route) => false,
    );
  }

  List<String> get authors =>
      _books.map((b) => b['autor'] as String).toSet().toList();

  List<String> get categories =>
      _books.map((b) => b['area'] as String).toSet().toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
        title: Text("Hola, ${widget.userName}",
            style: const TextStyle(color: textColor)),
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
    final bool selected = _selectedIndex == index;

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
        PopupMenuItem(
          value: "logout",
          child: Text("Cerrar sesión",
              style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildBooks() {
    final filtered = _books.where((b) {
      final q = _searchQuery.toLowerCase();
      return b['titulo'].toLowerCase().contains(q) &&
          (_selectedAuthor == null || b['autor'] == _selectedAuthor) &&
          (_selectedCategory == null || b['area'] == _selectedCategory);
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

          // 🔹 FILTROS
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
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
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
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: _buildBooksGrid(filtered),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksGrid(List<Map<String, dynamic>> books) {
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
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4),
            ],
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
                  book['titulo'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['titulo'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book['autor'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primaryColor),
                        ),
                        child: Text(
                          book['area'],
                          style: const TextStyle(
                            fontSize: 10,
                            color: primaryColor,
                          ),
                        ),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: _loans.length,
        itemBuilder: (context, index) {
          final loan = _loans[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loan['libro'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Fecha: ${loan['fecha']}"),
                Text("Devolución: ${loan['devolucion']}"),
                Text("Estado: ${loan['estado']}"),
              ],
            ),
          );
        },
      ),
    );
  }
}