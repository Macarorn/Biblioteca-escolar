import 'package:flutter/material.dart';
import '../widgets/change_password_dialog.dart';
import 'book_detail_screen.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  final String userName;
  final String userRole;

  const AdminDashboard({
    super.key,
    required this.userName,
    this.userRole = 'admin',
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  //  Colores reutilizables
  static const _backgroundColor = Color(0xFFEAE2D7);
  static const _cardColor = Color(0xFFF3EFE7);
  static const _primaryColor = Color(0xFF8D7B68);
  static const _textColor = Color(0xFF4E342E);
  static const _itemColor = Color(0xFFFAF9F6);
  static const _accentColor = Color(0xFFD7CCC8);

  int _selectedIndex = 0;
  int _booksTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();
  String _bookSearchQuery = '';
  String? _selectedCategoryFilter;
  bool _showAvailableOnly = false;

  // Data for solicitudes
  final List<Map<String, dynamic>> _solicitudes = [
    {
      'id': 1,
      'usuario': 'Juan Pérez',
      'libro': 'Cien Años de Soledad',
      'ejemplar': 'CAS-001',
      'fecha': '2026-02-15',
      'estado': 'pendiente',
    },
    {
      'id': 2,
      'usuario': 'María González',
      'libro': 'Don Quijote de la Mancha',
      'ejemplar': 'DQM-002',
      'fecha': '2026-02-16',
      'estado': 'pendiente',
    },
    {
      'id': 3,
      'usuario': 'Carlos López',
      'libro': 'Física para Secundaria',
      'ejemplar': 'FPS-003',
      'fecha': '2026-02-10',
      'estado': 'aprobada',
    },
    {
      'id': 4,
      'usuario': 'Ana Torres',
      'libro': 'Álgebra Básica',
      'ejemplar': 'ALG-001',
      'fecha': '2026-02-12',
      'estado': 'rechazada',
    },
  ];

  // Data for loans
  final List<Map<String, dynamic>> _loans = [
    {
      'book': 'Don Quijote de la Mancha',
      'user': 'Juan Pérez',
      'ejemplar': 'DQM-002',
      'loanDate': '2026-02-01',
      'returnDate': '2026-02-15',
      'status': 'Prestado',
    },
    {
      'book': 'Física para Secundaria',
      'user': 'María González',
      'ejemplar': 'FPS-003',
      'loanDate': '2026-01-20',
      'returnDate': '2026-01-27',
      'status': 'Devuelto',
      'condicionDevolucion': 'bueno',
      'observaciones': '',
      'fechaDevolucion': '2026-01-26',
    },
  ];

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

  // ── Helpers reutilizables ──

  List<Widget> _buildDialogActions({
    required VoidCallback onConfirm,
    String confirmLabel = 'Guardar',
  }) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar', style: TextStyle(color: _textColor)),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
        onPressed: onConfirm,
        child: Text(confirmLabel),
      ),
    ];
  }

  void _showDeleteConfirmation({
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor,
        title: const Text('Confirmar', style: TextStyle(color: _textColor)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: _textColor)),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
        backgroundColor: _cardColor,
        title: Text(
          isEditing ? 'Editar Usuario' : 'Nuevo Usuario',
          style: const TextStyle(color: _textColor),
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
                  initialValue: role,
                  dropdownColor: _cardColor,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items:
                      const [
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
        actions: _buildDialogActions(
          onConfirm: () {
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
        ),
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
        backgroundColor: _cardColor,
        title: Text(
          isEditing ? 'Editar Libro' : 'Nuevo Libro',
          style: const TextStyle(color: _textColor),
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
        actions: _buildDialogActions(
          onConfirm: () {
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
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final categories =
        _books.map((b) => b['category'] as String).toSet().toList()..sort();

    showDialog(
      context: context,
      builder: (context) {
        String? tempCategory = _selectedCategoryFilter;
        bool tempAvailable = _showAvailableOnly;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _cardColor,
              title: const Text('Filtros', style: TextStyle(color: _textColor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey(tempCategory),
                    initialValue: tempCategory,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    dropdownColor: _cardColor,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...categories.map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      ),
                    ].toList(),
                    onChanged: (v) => setDialogState(() => tempCategory = v),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Solo Disponibles'),
                    value: tempAvailable,
                    activeTrackColor: _primaryColor,
                    onChanged: (v) => setDialogState(() => tempAvailable = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
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
                    style: TextStyle(color: _textColor),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
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
        backgroundColor: _cardColor,
        title: const Text(
          'Nuevo Préstamo',
          style: TextStyle(color: _textColor),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Libro'),
                  dropdownColor: _cardColor,
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
                  dropdownColor: _cardColor,
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
                              primary: _primaryColor,
                              onPrimary: Colors.white,
                              onSurface: _textColor,
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
        actions: _buildDialogActions(
          confirmLabel: 'Prestar',
          onConfirm: () {
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTabs(),
                    const SizedBox(height: 16),
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    Widget content;
    switch (_selectedIndex) {
      case 0:
        content = _buildUserManagement();
        break;
      case 1:
        content = _buildBooksManagement();
        break;
      case 2:
        content = _buildSolicitudesView();
        break;
      default:
        content = Center(
          child: Text(
            'Contenido $_selectedIndex',
            style: const TextStyle(color: _textColor),
          ),
        );
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }

  Widget _buildHeader() {
    return Container(
      color: _cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: _accentColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book, color: _textColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Panel Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textColor,
                  ),
                ),
                Text(
                  'Hola, ${widget.userName}',
                  style: TextStyle(
                    color: _textColor.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: _textColor),
            color: _cardColor,
            onSelected: (value) {
              if (value == 'change_password') {
                _showChangePasswordDialog();
              } else if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem(
                value: 'change_password',
                child: Row(
                  children: [
                    Icon(Icons.vpn_key_outlined, size: 18, color: _textColor),
                    SizedBox(width: 8),
                    Text(
                      'Cambiar Contraseña',
                      style: TextStyle(color: _textColor),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: _textColor),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión', style: TextStyle(color: _textColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabItem(0, 'Usuarios', Icons.people_outline),
          _buildTabItem(1, 'Libros', Icons.book_outlined),
          _buildTabItem(2, 'Solicitudes', Icons.inbox_outlined),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : _textColor.withValues(alpha: 0.5),
              ),
              if (MediaQuery.of(context).size.width > 400) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: isSelected
                        ? Colors.white
                        : _textColor.withValues(alpha: 0.5),
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
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _textColor.withValues(alpha: 0.6),
                      ),
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
                  backgroundColor: _primaryColor,
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

  Widget _buildActionButtons({VoidCallback? onDelete, VoidCallback? onEdit}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_outlined,
              color: _textColor.withValues(alpha: 0.5),
            ),
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

  Widget _buildUserManagement() {
    return _buildManagementLayout(
      title: 'Gestión de Usuarios',
      subtitle: 'Administra los usuarios del sistema',
      buttonText: 'Nuevo Usuario',
      onPressed: _showAddUserDialog,
      child: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = _users[index];
          return Container(
            decoration: BoxDecoration(
              color: _itemColor,
              borderRadius: BorderRadius.circular(8),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _textColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _textColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user['role'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: _textColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Doc: ${user['doc']}',
                        style: TextStyle(
                          color: _textColor.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        user['email'] as String,
                        style: TextStyle(
                          color: _textColor.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(
                  onDelete: () => _showDeleteConfirmation(
                    message: '¿Eliminar usuario?',
                    onConfirm: () => setState(() => _users.removeAt(index)),
                  ),
                  onEdit: () => _showAddUserDialog(user: user, index: index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBooksManagement() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: _textColor.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSubTab('Catálogo', 0),
              _buildSubTab('Préstamos', 1),
            ],
          ),
        ),
        Expanded(
          child: _booksTabIndex == 0 ? _buildBookCatalog() : _buildLoansView(),
        ),
      ],
    );
  }

  Widget _buildSubTab(String label, int index) {
    final isSelected = _booksTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _booksTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : _textColor.withValues(alpha: 0.6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoansView() {
    // Separar préstamos activos de devueltos
    final activos = _loans.where((l) => l['status'] == 'Prestado').toList();
    final devueltos = _loans.where((l) => l['status'] == 'Devuelto').toList();

    return _buildManagementLayout(
      title: 'Préstamos',
      subtitle: 'Gestiona préstamos y devoluciones',
      buttonText: 'Nuevo Préstamo',
      onPressed: _showAddLoanDialog,
      child: ListView(
        children: [
          // ── Sección: Pendientes de devolución ──
          _buildLoanSectionHeader(
            icon: Icons.schedule,
            label: 'Pendientes de devolución',
            count: activos.length,
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
          if (activos.isEmpty)
            _buildEmptyLoanMessage('No hay préstamos activos')
          else
            ...activos.map(
              (loan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildActiveLoanCard(loan),
              ),
            ),
          const SizedBox(height: 24),
          // ── Sección: Devueltos ──
          _buildLoanSectionHeader(
            icon: Icons.check_circle,
            label: 'Devueltos',
            count: devueltos.length,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          if (devueltos.isEmpty)
            _buildEmptyLoanMessage('No hay devoluciones registradas')
          else
            ...devueltos.map(
              (loan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReturnedLoanCard(loan),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoanSectionHeader({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _textColor.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyLoanMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _itemColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accentColor),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: _textColor.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _buildActiveLoanCard(Map<String, dynamic> loan) {
    final returnDate = DateTime.parse(loan['returnDate']);
    final now = DateTime.now();
    final isOverdue = returnDate.isBefore(now);
    final daysLeft = returnDate.difference(now).inDays;

    return Container(
      decoration: BoxDecoration(
        color: _itemColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue ? Colors.red.withValues(alpha: 0.4) : _accentColor,
          width: isOverdue ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado con estado ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isOverdue
                  ? Colors.red.withValues(alpha: 0.08)
                  : _primaryColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isOverdue ? Icons.warning_amber_rounded : Icons.menu_book,
                  size: 16,
                  color: isOverdue ? Colors.red : _primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  isOverdue
                      ? 'Vencido hace ${-daysLeft} día${-daysLeft == 1 ? '' : 's'}'
                      : daysLeft == 0
                      ? 'Vence hoy'
                      : 'Vence en $daysLeft día${daysLeft == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? Colors.red : _primaryColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? Colors.red.withValues(alpha: 0.1)
                        : _primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ACTIVO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isOverdue ? Colors.red : _primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Cuerpo ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan['book'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildLoanInfoRow(
                  Icons.person_outline,
                  'Usuario',
                  loan['user'],
                ),
                const SizedBox(height: 4),
                _buildLoanInfoRow(
                  Icons.qr_code,
                  'Ejemplar',
                  loan['ejemplar'] ?? '-',
                ),
                const SizedBox(height: 4),
                _buildLoanInfoRow(
                  Icons.calendar_today,
                  'Prestado',
                  loan['loanDate'],
                ),
                const SizedBox(height: 4),
                _buildLoanInfoRow(Icons.event, 'Vence', loan['returnDate']),
                const SizedBox(height: 16),
                // ── Botón claro de devolución ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showReturnLoanDialog(loan),
                    icon: const Icon(Icons.assignment_return, size: 18),
                    label: const Text('Registrar Devolución'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnedLoanCard(Map<String, dynamic> loan) {
    return Container(
      decoration: BoxDecoration(
        color: _itemColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan['book'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${loan['user']} · Devuelto ${loan['fechaDevolucion'] ?? loan['returnDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textColor.withValues(alpha: 0.6),
                  ),
                ),
                if (loan['condicionDevolucion'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Condición: ${loan['condicionDevolucion']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _textColor.withValues(alpha: 0.4)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: _textColor.withValues(alpha: 0.5),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _textColor.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildBookCatalog() {
    final filteredBooks = _books.where((book) {
      final q = _bookSearchQuery.toLowerCase();
      final title = (book['title'] as String).toLowerCase();
      final author = (book['author'] as String).toLowerCase();
      final category = (book['category'] as String).toLowerCase();

      final matchesQuery =
          title.contains(q) || author.contains(q) || category.contains(q);
      final matchesCategory =
          _selectedCategoryFilter == null ||
          book['category'] == _selectedCategoryFilter;
      final matchesAvailability =
          !_showAvailableOnly || (book['available'] as int) > 0;

      return matchesQuery && matchesCategory && matchesAvailability;
    }).toList();

    return _buildManagementLayout(
      title: 'Catálogo de Libros',
      subtitle: 'Administra y busca libros',
      buttonText: 'Nuevo Libro',
      onPressed: _showAddBookDialog,
      child: Column(
        children: [
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
                        ? _primaryColor
                        : Colors.black,
                  ),
                  tooltip: 'Filtros',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filteredBooks.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailScreen(book: book),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _itemColor,
                      borderRadius: BorderRadius.circular(8),
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book['author'] as String,
                                style: TextStyle(
                                  color: _textColor.withValues(alpha: 0.6),
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
                                      color: _textColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      book['category'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _textColor.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${book['available']}/${book['total']} disponibles',
                                    style: TextStyle(
                                      color: _textColor.withValues(alpha: 0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildActionButtons(
                          onDelete: () {
                            final originalIndex = _books.indexOf(book);
                            if (originalIndex != -1) {
                              _showDeleteConfirmation(
                                message: '¿Eliminar libro?',
                                onConfirm: () => setState(
                                  () => _books.removeAt(originalIndex),
                                ),
                              );
                            }
                          },
                          onEdit: () {
                            final originalIndex = _books.indexOf(book);
                            if (originalIndex != -1) {
                              _showAddBookDialog(
                                book: book,
                                index: originalIndex,
                              );
                            }
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

  // ── Devolución ──

  void _showReturnLoanDialog(Map<String, dynamic> loan) {
    String condition = 'bueno';
    final observacionesController = TextEditingController();
    final returnDate = DateTime.parse(loan['returnDate']);
    final isOverdue = returnDate.isBefore(DateTime.now());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.assignment_return,
                    color: _primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registrar Devolución',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Completa los datos para finalizar el préstamo',
                        style: TextStyle(color: _primaryColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Resumen del préstamo ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _itemColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _accentColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan['book'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildDialogInfoRow(Icons.person_outline, loan['user']),
                      const SizedBox(height: 3),
                      _buildDialogInfoRow(
                        Icons.qr_code,
                        'Ejemplar: ${loan['ejemplar'] ?? "-"}',
                      ),
                      const SizedBox(height: 3),
                      _buildDialogInfoRow(
                        Icons.calendar_today,
                        'Prestado: ${loan['loanDate']}',
                      ),
                      const SizedBox(height: 3),
                      _buildDialogInfoRow(
                        Icons.event,
                        'Vencía: ${loan['returnDate']}',
                        color: isOverdue ? Colors.red : null,
                      ),
                    ],
                  ),
                ),
                if (isOverdue) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Este préstamo está vencido',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // ── Paso 1: Condición ──
                const Text(
                  '¿En qué condición se devuelve el libro?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildConditionChip(
                      'excelente',
                      'Excelente',
                      Colors.green,
                      condition,
                      (v) {
                        setDialogState(() => condition = v);
                      },
                    ),
                    _buildConditionChip(
                      'bueno',
                      'Bueno',
                      _primaryColor,
                      condition,
                      (v) {
                        setDialogState(() => condition = v);
                      },
                    ),
                    _buildConditionChip(
                      'regular',
                      'Regular',
                      Colors.orange,
                      condition,
                      (v) {
                        setDialogState(() => condition = v);
                      },
                    ),
                    _buildConditionChip('malo', 'Malo', Colors.red, condition, (
                      v,
                    ) {
                      setDialogState(() => condition = v);
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Paso 2: Observaciones ──
                const Text(
                  'Observaciones (opcional)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: observacionesController,
                  maxLines: 3,
                  style: const TextStyle(color: _textColor, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Ej: Lomo desgastado, páginas marcadas…',
                    hintStyle: TextStyle(
                      color: _textColor.withValues(alpha: 0.35),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: _itemColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _accentColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _accentColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _textColor,
                      side: BorderSide(
                        color: _textColor.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        loan['status'] = 'Devuelto';
                        loan['condicionDevolucion'] = condition;
                        loan['observaciones'] = observacionesController.text;
                        loan['fechaDevolucion'] = DateTime.now()
                            .toIso8601String()
                            .split('T')
                            .first;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Devolución de "${loan['book']}" registrada',
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Confirmar Devolución'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionChip(
    String value,
    String label,
    Color color,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : _itemColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : _accentColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : _textColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color ?? _textColor.withValues(alpha: 0.4)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color ?? _textColor.withValues(alpha: 0.7),
              fontWeight: color != null ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  // ── Bandeja de Solicitudes ──

  Widget _buildSolicitudesView() {
    final pendientes = _solicitudes
        .where((s) => s['estado'] == 'pendiente')
        .toList();
    final procesadas = _solicitudes
        .where((s) => s['estado'] != 'pendiente')
        .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bandeja de Solicitudes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${pendientes.length} pendiente(s)',
            style: TextStyle(color: _textColor.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 20),

          // Pendientes
          if (pendientes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: _itemColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'No hay solicitudes pendientes',
                  style: TextStyle(
                    color: _textColor.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: pendientes.length + procesadas.length + 1,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  // Header separador
                  if (index == pendientes.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 4),
                      child: Text(
                        'Procesadas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _textColor.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    );
                  }

                  final isPendienteSection = index < pendientes.length;
                  final solicitud = isPendienteSection
                      ? pendientes[index]
                      : procesadas[index - pendientes.length - 1];

                  return _buildSolicitudItem(solicitud);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSolicitudItem(Map<String, dynamic> solicitud) {
    final isPendiente = solicitud['estado'] == 'pendiente';
    final isAprobada = solicitud['estado'] == 'aprobada';

    final Color statusColor;
    if (isPendiente) {
      statusColor = Colors.orange;
    } else if (isAprobada) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      decoration: BoxDecoration(
        color: _itemColor,
        borderRadius: BorderRadius.circular(8),
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
                  solicitud['libro'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Solicitado por: ${solicitud['usuario']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ejemplar: ${solicitud['ejemplar']} • ${solicitud['fecha']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textColor.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    solicitud['estado'].toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isPendiente)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _aprobarSolicitud(solicitud),
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  tooltip: 'Aprobar',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: () => _rechazarSolicitud(solicitud),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  tooltip: 'Rechazar',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _aprobarSolicitud(Map<String, dynamic> solicitud) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor,
        title: const Text(
          'Aprobar Solicitud',
          style: TextStyle(color: _textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Aprobar la solicitud de "${solicitud['libro']}" para ${solicitud['usuario']}?',
            ),
            const SizedBox(height: 12),
            Text(
              'Esto creará un préstamo activo y marcará el ejemplar como prestado.',
              style: TextStyle(
                fontSize: 12,
                color: _textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: _buildDialogActions(
          confirmLabel: 'Aprobar',
          onConfirm: () {
            setState(() {
              solicitud['estado'] = 'aprobada';
              // Crear préstamo automáticamente
              _loans.insert(0, {
                'book': solicitud['libro'],
                'user': solicitud['usuario'],
                'loanDate': DateTime.now().toString().split(' ')[0],
                'returnDate': DateTime.now()
                    .add(const Duration(days: 15))
                    .toString()
                    .split(' ')[0],
                'status': 'Prestado',
              });
            });
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solicitud aprobada — Préstamo creado'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  void _rechazarSolicitud(Map<String, dynamic> solicitud) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor,
        title: const Text(
          'Rechazar Solicitud',
          style: TextStyle(color: _textColor),
        ),
        content: Text(
          '¿Rechazar la solicitud de "${solicitud['libro']}" de ${solicitud['usuario']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: _textColor)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                solicitud['estado'] = 'rechazada';
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Solicitud rechazada'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Rechazar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
