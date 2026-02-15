import 'package:flutter/material.dart';
import '../widgets/change_password_dialog.dart';
import 'book_detail_screen.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  final String userName;
  final String
  userRole; // Add role to differentiate if needed, though UI is same

  const AdminDashboard({
    super.key,
    required this.userName,
    this.userRole = 'admin',
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int _booksTabIndex = 0; // 0: Catalog, 1: Loans
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();
  String _bookSearchQuery = '';
  String? _selectedCategoryFilter;
  bool _showAvailableOnly = false;

  // Data for loans
  final List<Map<String, dynamic>> _loans = [
    {
      'book': 'Don Quijote de la Mancha',
      'user': 'Juan Pérez',
      'loanDate': '2023-10-01',
      'returnDate': '2023-10-15',
      'status': 'Prestado',
    },
    {
      'book': 'Física para Secundaria',
      'user': 'María González',
      'loanDate': '2023-09-20',
      'returnDate': '2023-09-27',
      'status': 'Devuelto',
    },
  ];

  // Lists moved to state for modification
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Juan Pérez',
      'role': 'estudiante',
      'doc': '1001',
      'email': 'juan@estudiante.com',
    },
    {
      'name': 'María González',
      'role': 'profesor',
      'doc': '2001',
      'email': 'maria@profesor.com',
    },
    {
      'name': 'Ana Martínez',
      'role': 'administrador',
      'doc': '4001',
      'email': 'ana@admin.com',
    },
  ];

  final List<Map<String, dynamic>> _books = [
    {
      'title': 'Cien Años de Soledad',
      'author': 'Gabriel García Márquez',
      'category': 'Literatura',
      'available': 3,
      'total': 5,
    },
    {
      'title': 'Don Quijote de la Mancha',
      'author': 'Miguel de Cervantes',
      'category': 'Literatura',
      'available': 2,
      'total': 4,
    },
    {
      'title': 'Física para Secundaria',
      'author': 'Antonio López',
      'category': 'Ciencias',
      'available': 5,
      'total': 6,
    },
    {
      'title': 'Historia Universal',
      'author': 'Laura Fernández',
      'category': 'Historia',
      'available': 0,
      'total': 3,
    },
    {
      'title': 'Álgebra Básica',
      'author': 'Roberto Sánchez',
      'category': 'Matemáticas',
      'available': 4,
      'total': 4,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _showChangePasswordDialog(mandatory: true);
    });
  }

  void _showChangePasswordDialog({bool mandatory = false}) {
    showDialog(
      context: context,
      barrierDismissible: !mandatory,
      builder: (context) => ChangePasswordDialog(isMandatory: mandatory),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  void _showAddUserDialog({Map<String, dynamic>? user, int? index}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user?['name']);
    final docController = TextEditingController(text: user?['doc']);
    final emailController = TextEditingController(text: user?['email']);
    String role = user?['role'] ?? 'estudiante';
    final isEditing = user != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF3EFE7),
        title: Text(
          isEditing ? 'Editar Usuario' : 'Nuevo Usuario',
          style: const TextStyle(color: Color(0xFF4E342E)),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: docController,
                  decoration: const InputDecoration(labelText: 'Documento'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                DropdownButtonFormField<String>(
                  value: role,
                  dropdownColor: const Color(0xFFF3EFE7),
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items:
                      [
                            'estudiante',
                            'profesor',
                            'bibliotecario',
                            'administrador',
                          ]
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                  onChanged: (v) => role = v!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF4E342E)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D7B68),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  final newUser = {
                    'name': nameController.text,
                    'role': role,
                    'doc': docController.text,
                    'email': emailController.text,
                  };
                  if (isEditing) {
                    _users[index!] = newUser;
                  } else {
                    _users.add(newUser);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAddBookDialog({Map<String, dynamic>? book, int? index}) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: book?['title']);
    final authorController = TextEditingController(text: book?['author']);
    final categoryController = TextEditingController(text: book?['category']);
    final totalController = TextEditingController(
      text: book?['total']?.toString(),
    );
    final isEditing = book != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF3EFE7),
        title: Text(
          isEditing ? 'Editar Libro' : 'Nuevo Libro',
          style: const TextStyle(color: Color(0xFF4E342E)),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Autor'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Categoría/Área',
                  ),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: totalController,
                  decoration: const InputDecoration(
                    labelText: 'Total Ejemplares',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF4E342E)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D7B68),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  final newBook = {
                    'title': titleController.text,
                    'author': authorController.text,
                    'category': categoryController.text,
                    'available': int.tryParse(totalController.text) ?? 0,
                    'total': int.tryParse(totalController.text) ?? 0,
                  };
                  if (isEditing) {
                    _books[index!] = newBook;
                  } else {
                    _books.add(newBook);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF3EFE7),
        title: const Text(
          "Confirmar",
          style: TextStyle(color: Color(0xFF4E342E)),
        ),
        content: const Text("¿Eliminar usuario?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Color(0xFF4E342E)),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _users.removeAt(index));
              Navigator.pop(ctx);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteBook(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF3EFE7),
        title: const Text(
          "Confirmar",
          style: TextStyle(color: Color(0xFF4E342E)),
        ),
        content: const Text("¿Eliminar libro?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Color(0xFF4E342E)),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _books.removeAt(index));
              Navigator.pop(ctx);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // Get unique categories
    final categories =
        _books.map((b) => b['category'] as String).toSet().toList()..sort();

    showDialog(
      context: context,
      builder: (context) {
        String? tempCategory = _selectedCategoryFilter;
        bool tempAvailable = _showAvailableOnly;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF3EFE7),
              title: const Text(
                'Filtros',
                style: TextStyle(color: Color(0xFF4E342E)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: tempCategory,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    dropdownColor: const Color(0xFFF3EFE7),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...categories.map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      ),
                    ].toList(),
                    onChanged: (v) => setState(() => tempCategory = v),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Solo Disponibles'),
                    value: tempAvailable,
                    activeColor: const Color(0xFF8D7B68),
                    onChanged: (v) => setState(() => tempAvailable = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      tempCategory = null;
                      tempAvailable = false;
                    });
                  },
                  child: const Text(
                    'Limpiar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFF4E342E)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D7B68),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    this.setState(() {
                      _selectedCategoryFilter = tempCategory;
                      _showAvailableOnly = tempAvailable;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddLoanDialog() {
    final formKey = GlobalKey<FormState>();
    String? selectedBook;
    String? selectedUser;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 15));
    final dateController = TextEditingController(
      text: selectedDate.toString().split(' ')[0],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF3EFE7),
        title: const Text(
          'Nuevo Préstamo',
          style: TextStyle(color: Color(0xFF4E342E)),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Libro'),
                  dropdownColor: const Color(0xFFF3EFE7),
                  items: _books.map((book) {
                    return DropdownMenuItem<String>(
                      value: book['title'] as String,
                      child: SizedBox(
                        width: 200,
                        child: Text(
                          book['title'] as String,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => selectedBook = v,
                  validator: (v) => v == null ? 'Seleccione un libro' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Usuario'),
                  dropdownColor: const Color(0xFFF3EFE7),
                  items: _users.map((user) {
                    return DropdownMenuItem<String>(
                      value: user['name'] as String,
                      child: Text(user['name'] as String),
                    );
                  }).toList(),
                  onChanged: (v) => selectedUser = v,
                  validator: (v) => v == null ? 'Seleccione un usuario' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha Devolución Estimada',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF8D7B68),
                              onPrimary: Colors.white,
                              onSurface: Color(0xFF4E342E),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      selectedDate = picked;
                      dateController.text = picked.toString().split(' ')[0];
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF4E342E)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D7B68),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _loans.insert(0, {
                    'book': selectedBook,
                    'user': selectedUser,
                    'loanDate': DateTime.now().toString().split(' ')[0],
                    'returnDate': dateController.text,
                    'status': 'Prestado',
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Prestar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definir paleta de colores
    final backgroundColor = Color(0xFFEAE2D7);
    final cardColor = Color(0xFFF3EFE7);
    final primaryColor = Color(0xFF8D7B68);
    final textColor = Color(0xFF4E342E);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(cardColor, textColor, primaryColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTabs(cardColor, textColor, primaryColor),
                    const SizedBox(height: 16),
                    Expanded(child: _buildContent(textColor)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    Widget content;
    switch (_selectedIndex) {
      case 0:
        content = _buildUserManagement(textColor);
        break;
      case 1:
        content = _buildBooksManagement(textColor);
        break;
      default:
        content = Center(
          child: Text(
            "Contenido $_selectedIndex",
            style: TextStyle(color: textColor),
          ),
        );
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE7),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }

  Widget _buildHeader(Color cardColor, Color textColor, Color primaryColor) {
    return Container(
      color: cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFD7CCC8),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.menu_book, color: textColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Panel Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Text(
                  'Hola, ${widget.userName}',
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textColor),
            color: cardColor,
            onSelected: (value) {
              if (value == 'change_password') {
                _showChangePasswordDialog();
              } else if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(onLogin: (u, p) => true),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'change_password',
                  child: Row(
                    children: [
                      Icon(Icons.vpn_key_outlined, size: 18, color: textColor),
                      const SizedBox(width: 8),
                      Text(
                        'Cambiar Contraseña',
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18, color: textColor),
                      const SizedBox(width: 8),
                      Text('Cerrar Sesión', style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Color cardColor, Color textColor, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabItem(
            0,
            'Usuarios',
            Icons.people_outline,
            textColor,
            primaryColor,
          ),
          _buildTabItem(
            1,
            'Libros',
            Icons.book_outlined,
            textColor,
            primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    int index,
    String label,
    IconData icon,
    Color textColor,
    Color primaryColor,
  ) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : textColor.withOpacity(0.5),
              ),
              if (MediaQuery.of(context).size.width > 400) ...[
                // Increased threshold for 4 items
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10, // Smaller font
                    color: isSelected
                        ? Colors.white
                        : textColor.withOpacity(0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementLayout({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    required Widget child,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: textColor.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.add, size: 18),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D7B68),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    Color textColor,
    VoidCallback? onDelete,
    VoidCallback? onEdit,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, color: textColor.withOpacity(0.5)),
            tooltip: 'Editar',
            visualDensity: VisualDensity.compact,
          ),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Eliminar',
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Widget _buildUserManagement(Color textColor) {
    return _buildManagementLayout(
      title: 'Gestión de Usuarios',
      subtitle: 'Administra los usuarios del sistema',
      buttonText: 'Nuevo Usuario',
      onPressed: _showAddUserDialog,
      textColor: textColor,
      child: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = _users[index];
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAF9F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.transparent),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user['name'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: textColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user['role'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Doc: ${user['doc']}',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        user['email'] as String,
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(
                  textColor,
                  () => _deleteUser(index),
                  () => _showAddUserDialog(user: user, index: index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBooksManagement(Color textColor) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: textColor.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSubTab('Catálogo', 0, textColor),
              _buildSubTab('Préstamos', 1, textColor),
            ],
          ),
        ),
        Expanded(
          child: _booksTabIndex == 0
              ? _buildBookCatalog(textColor)
              : _buildLoansView(textColor),
        ),
      ],
    );
  }

  Widget _buildSubTab(String label, int index, Color textColor) {
    final isSelected = _booksTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _booksTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8D7B68) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor.withOpacity(0.6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoansView(Color textColor) {
    return _buildManagementLayout(
      title: 'Préstamos Activos',
      subtitle: 'Administra los préstamos',
      buttonText: 'Nuevo Préstamo',
      onPressed: _showAddLoanDialog,
      textColor: textColor,
      child: ListView.separated(
        itemCount: _loans.length,
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final loan = _loans[index];
          final isOverdue =
              DateTime.parse(loan['returnDate']).isBefore(DateTime.now()) &&
              loan['status'] == 'Prestado';

          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAF9F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.transparent),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan['book'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Usuario: ${loan['user']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Hasta: ${loan['returnDate']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue
                                  ? Colors.red
                                  : textColor.withOpacity(0.6),
                              fontWeight: isOverdue
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: loan['status'] == 'Prestado'
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              loan['status'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: loan['status'] == 'Prestado'
                                    ? Colors.blue
                                    : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (loan['status'] == 'Prestado')
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    tooltip: 'Registrar Devolución',
                    onPressed: () {
                      setState(() {
                        loan['status'] = 'Devuelto';
                      });
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookCatalog(Color textColor) {
    final filteredBooks = _books.where((book) {
      final q = _bookSearchQuery.toLowerCase();
      final title = (book['title'] as String).toLowerCase();
      final author = (book['author'] as String).toLowerCase();
      final category = (book['category'] as String).toLowerCase();

      bool matchesQuery =
          title.contains(q) || author.contains(q) || category.contains(q);
      bool matchesCategory =
          _selectedCategoryFilter == null ||
          book['category'] == _selectedCategoryFilter;
      bool matchesAvailability =
          !_showAvailableOnly || (book['available'] as int) > 0;

      return matchesQuery && matchesCategory && matchesAvailability;
    }).toList();

    return _buildManagementLayout(
      title: 'Catálogo de Libros',
      subtitle: 'Administra y busca libros',
      buttonText: 'Nuevo Libro',
      onPressed: _showAddBookDialog,
      textColor: textColor,
      child: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _bookSearchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Buscar por título, autor o área...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showFilterDialog,
                  icon: Icon(
                    Icons.filter_list,
                    color:
                        (_selectedCategoryFilter != null || _showAvailableOnly)
                        ? const Color(0xFF8D7B68)
                        : Colors.black,
                  ),
                  tooltip: 'Filtros',
                ),
              ],
            ),
          ),
          // Book List
          Expanded(
            child: ListView.separated(
              itemCount: filteredBooks.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailScreen(book: book),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF9F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.transparent),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book['author'] as String,
                                style: TextStyle(
                                  color: textColor.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: textColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      book['category'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: textColor.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${book['available']}/${book['total']} disponibles',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildActionButtons(
                          textColor,
                          () {
                            final originalIndex = _books.indexOf(book);
                            if (originalIndex != -1) {
                              _deleteBook(originalIndex);
                            }
                          },
                          () {
                            final originalIndex = _books.indexOf(book);
                            if (originalIndex != -1)
                              _showAddBookDialog(
                                book: book,
                                index: originalIndex,
                              );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
