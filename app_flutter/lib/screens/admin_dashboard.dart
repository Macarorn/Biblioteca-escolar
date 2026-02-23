import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/libros_service.dart';
import '../widgets/change_password_dialog.dart';
import 'book_detail_screen.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  /// El nombre del usuario actualmente conectado.
  final String userName;

  /// El rol del usuario .
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
  // Colores reutilizables para la interfaz de usuario.
  static const _backgroundColor = Color(0xFFEAE2D7);
  static const _cardColor = Color(0xFFF3EFE7);
  static const _primaryColor = Color(0xFF8D7B68);
  static const _textColor = Color(0xFF4E342E);
  static const _itemColor = Color(0xFFFAF9F6);
  static const _accentColor = Color(0xFFD7CCC8);

  int _selectedIndex = 0;
  int _booksTabIndex = 0;
  Timer? _solicitudesTimer;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _loanDateFromController = TextEditingController();
  final TextEditingController _loanDateToController = TextEditingController();
  String _bookSearchQuery = '';
  String? _selectedCategoryFilter;
  bool _showAvailableOnly = false;

  // Estado de carga
  late LibrosService _librosService;
  bool _dataLoaded = false;
  bool _isLoadingBooks = false;
  bool _isLoadingLoans = false;
  bool _isLoadingSolicitudes = false;

  // Datos
  List<Map<String, dynamic>> _solicitudes = [];
  List<Map<String, dynamic>> _loans = [];
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoadingUsers = false;

  // Filtros
  String _loanFilterStatus = 'todos';
  String _loanFilterUser = '';
  DateTime? _loanFilterDateFrom;
  DateTime? _loanFilterDateTo;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // iniciar polling cada 10 segundos para refrescar las solicitudes automáticamente
      _solicitudesTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (mounted) _loadSolicitudes();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _dataLoaded = true;
      _librosService = context.read<LibrosService>();
      _loadBooks();
      _loadLoans();
      _loadSolicitudes();
      _loadUsers();
    }
  }

  //   Métodos de carga desde API

  int _toInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    return date.toString().split('T')[0];
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoadingBooks = true);
    try {
      final libros = await _librosService.getLibros();
      final books = <Map<String, dynamic>>[];
      for (final libro in libros) {
        Map<String, dynamic> disp = {'total': 0, 'disponibles': 0};
        try {
          disp = await _librosService.getDisponibilidad(libro['id_libro']);
        } catch (_) {}
        books.add({
          ...libro,
          'id_libro': _toInt(libro['id_libro']),
          'title': libro['titulo'] ?? '',
          'author': libro['autor'] ?? '',
          'category': libro['area'] ?? '',
          'available': _toInt(disp['disponibles']),
          'total': _toInt(disp['total']),
        });
      }
      if (mounted)
        setState(() {
          _books = books;
          _isLoadingBooks = false;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBooks = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar libros: $e')));
      }
    }
  }

  Future<void> _loadLoans() async {
    setState(() => _isLoadingLoans = true);
    try {
      final prestamos = await _librosService.getPrestamos();
      final loans = prestamos
          .map(
            (p) => <String, dynamic>{
              ...p,
              'book': p['titulo'] ?? '',
              'user': '${p['nombre'] ?? ''} ${p['apellido'] ?? ''}'.trim(),
              'ejemplar': p['codigo_ejemplar'] ?? '-',
              'loanDate': _formatDate(p['fecha_prestamo']),
              'returnDate': _formatDate(p['fecha_devolucion']),
              'status': p['estado'] == 'activo' ? 'Prestado' : 'Devuelto',
            },
          )
          .toList();
      if (mounted)
        setState(() {
          _loans = loans;
          _isLoadingLoans = false;
        });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLoans = false;
        });
      }
    }
  }

  Future<void> _loadSolicitudes() async {
    setState(() => _isLoadingSolicitudes = true);
    try {
      final solis = await _librosService.getSolicitudes();
      final solicitudes = solis
          .map(
            (s) => <String, dynamic>{
              ...s,
              'id': _toInt(s['id_solicitud']),
              'usuario': '${s['nombre'] ?? ''} ${s['apellido'] ?? ''}'.trim(),
              'libro': s['titulo'] ?? '',
              'fecha': _formatDate(s['fecha_solicitud']),
            },
          )
          .toList();
      if (mounted) {
        setState(() {
          _solicitudes = solicitudes;
          _isLoadingSolicitudes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSolicitudes = false;
        });
      }
    }
  }

  /// Carga los usuarios desde la API y los transforma para la UI
  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final usuarios = await _librosService.getUsuarios();
      final list = usuarios.map((u) {
        return {
          'id_usuario': _toInt(u['id_usuario']),
          'nombre': u['nombre'] ?? '',
          'apellido': u['apellido'] ?? '',
          'role': u['tipo_usuario'] ?? '',
          'doc': u['documento'] ?? '',
          'email': u['email'] ?? '', // la base de datos no tiene correo,
          // este campo queda vacío por ahora
        };
      }).toList();
      if (mounted) {
        setState(() {
          _users = list;
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
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
    _solicitudesTimer?.cancel();
    _searchController.dispose();
    _userSearchController.dispose();
    _loanDateFromController.dispose();
    _loanDateToController.dispose();
    super.dispose();
  }

  /// devuelve una contraseña aleatoria de longitud `len`
  String _randomPassword(int len) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(len, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  void _showAddUserDialog({Map<String, dynamic>? user, int? index}) {
    final formKey = GlobalKey<FormState>();
    final firstController = TextEditingController(text: user?['nombre']);
    final lastController = TextEditingController(text: user?['apellido']);
    final docController = TextEditingController(text: user?['doc']);
    final emailController = TextEditingController(text: user?['email']);
    final passwordController = TextEditingController();
    bool showPassword = false;
    String role = user?['role'] ?? 'estudiante';
    final isEditing = user != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                    controller: firstController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: lastController,
                    decoration: const InputDecoration(labelText: 'Apellido'),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: docController,
                    decoration: const InputDecoration(labelText: 'Documento'),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email (opcional)',
                    ),
                  ),
                  if (!isEditing) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setDialogState(
                            () => showPassword = !showPassword,
                          ),
                        ),
                      ),
                      obscureText: !showPassword,
                      // la contraseña puede quedar vacía y se generará una
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setDialogState(() {
                            final generated = _randomPassword(8);
                            passwordController.text = generated;
                          });
                        },
                        child: const Text('Generar aleatoria'),
                      ),
                    ),
                  ],
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
            onConfirm: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                String usedPassword = passwordController.text;
                if (!isEditing && usedPassword.isEmpty) {
                  usedPassword = _randomPassword(8);
                }
                try {
                  final data = {
                    'nombre': firstController.text,
                    'apellido': lastController.text,
                    'documento': docController.text,
                    'tipo_usuario': role,
                  };
                  if (!isEditing) {
                    data['contrasena'] = usedPassword;
                    await _librosService.createUsuario(data);
                  } else {
                    if (usedPassword.isNotEmpty) {
                      data['contrasena'] = usedPassword;
                    }
                    await _librosService.updateUsuario(
                      user['id_usuario'] ?? 0,
                      data,
                    );
                  }
                  _loadUsers();
                  if (!isEditing) {
                    // mostrar contraseña generada al administrador
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: _cardColor,
                          title: const Text(
                            'Contraseña creada',
                            style: TextStyle(color: _textColor),
                          ),
                          content: Text(
                            'La contraseña del usuario es: $usedPassword',
                            style: TextStyle(color: _textColor),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text(
                                'Aceptar',
                                style: TextStyle(color: _primaryColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
          ),
        ),
      ),
    );
  }

  void _showAddBookDialog({Map<String, dynamic>? book, int? index}) {
    final formKey = GlobalKey<FormState>();
    final codigoController = TextEditingController(text: book?['codigo_libro']);
    final titleController = TextEditingController(text: book?['title']);
    final authorController = TextEditingController(text: book?['author']);
    final categoryController = TextEditingController(text: book?['category']);
    final yearController = TextEditingController(
      text: book?['anio_publicacion']?.toString(),
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
                  controller: codigoController,
                  decoration: const InputDecoration(labelText: 'Código'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
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
                  decoration: const InputDecoration(labelText: 'Área'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: yearController,
                  decoration: const InputDecoration(
                    labelText: 'Año de Publicación',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: _buildDialogActions(
          onConfirm: () async {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context);
              try {
                final data = {
                  'codigo_libro': codigoController.text,
                  'titulo': titleController.text,
                  'autor': authorController.text,
                  'area': categoryController.text,
                  'anio_publicacion': int.tryParse(yearController.text),
                  'estado': book?['estado'] ?? 'activo',
                };
                if (isEditing) {
                  await _librosService.updateLibro(book!['id_libro'], data);
                } else {
                  await _librosService.createLibro(data);
                }
                _loadBooks();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
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
    Map<String, dynamic>? selectedUser;
    List<Map<String, dynamic>> ejemplaresDisponibles = [];
    Map<String, dynamic>? selectedEjemplar;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Libro'),
                    dropdownColor: _cardColor,
                    items: _books.where((b) => _toInt(b['available']) > 0).map((
                      book,
                    ) {
                      return DropdownMenuItem<int>(
                        value: _toInt(book['id_libro']),
                        child: SizedBox(
                          width: 200,
                          child: Text(
                            book['title'] as String,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (id) async {
                      // Cargar ejemplares disponibles del libro
                      try {
                        final ejs = await _librosService.getEjemplares(id!);
                        setDialogState(() {
                          ejemplaresDisponibles = ejs
                              .where((e) => e['disponibilidad'] == 'disponible')
                              .toList();
                          selectedEjemplar = null;
                        });
                      } catch (_) {}
                    },
                    validator: (v) => v == null ? 'Seleccione un libro' : null,
                  ),
                  const SizedBox(height: 16),
                  if (ejemplaresDisponibles.isNotEmpty)
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Ejemplar'),
                      dropdownColor: _cardColor,
                      items: ejemplaresDisponibles.map((ej) {
                        return DropdownMenuItem<int>(
                          value: _toInt(ej['id_ejemplar']),
                          child: Text(ej['codigo_ejemplar'] as String),
                        );
                      }).toList(),
                      onChanged: (id) {
                        selectedEjemplar = ejemplaresDisponibles.firstWhere(
                          (e) => e['id_ejemplar'] == id,
                        );
                      },
                      validator: (v) =>
                          v == null ? 'Seleccione un ejemplar' : null,
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Usuario'),
                    dropdownColor: _cardColor,
                    items: _users.map((user) {
                      final full = '${user['nombre']} ${user['apellido']}'
                          .trim();
                      return DropdownMenuItem<String>(
                        value: full,
                        child: Text(full),
                      );
                    }).toList(),
                    onChanged: (v) {
                      selectedUser = _users.firstWhere((u) {
                        final full = '${u['nombre']} ${u['apellido']}'.trim();
                        return full == v;
                      });
                    },
                    validator: (v) =>
                        v == null ? 'Seleccione un usuario' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: _buildDialogActions(
            confirmLabel: 'Prestar',
            onConfirm: () async {
              if (formKey.currentState!.validate() &&
                  selectedEjemplar != null) {
                Navigator.pop(context);
                try {
                  await _librosService.createPrestamo({
                    'id_usuario': selectedUser?['id_usuario'] ?? 1,
                    'id_ejemplar': selectedEjemplar!['id_ejemplar'],
                    'id_solicitud': null,
                  });
                  _loadLoans();
                  _loadBooks();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: _itemColor,
              prefixIconColor: _primaryColor,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
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
    if (_isLoadingUsers) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

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
          final fullName = '${user['nombre']} ${user['apellido']}'.trim();
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
                            fullName,
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
                      if ((user['email'] as String).isNotEmpty)
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
                    onConfirm: () async {
                      final id = user['id_usuario'];
                      if (id != null) {
                        try {
                          await _librosService.deleteUsuario(id);
                          _loadUsers();
                        } catch (_) {}
                      }
                    },
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
    if (_isLoadingLoans) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    // Aplicar filtros
    var filtered = _loans.where((l) {
      // Filtro por estado
      if (_loanFilterStatus != 'todos') {
        final matches = _loanFilterStatus == 'activo'
            ? l['status'] == 'Prestado'
            : l['status'] == 'Devuelto';
        if (!matches) return false;
      }

      // Filtro por usuario
      if (_loanFilterUser.isNotEmpty) {
        final user = (l['user'] ?? '').toString().toLowerCase();
        if (!user.contains(_loanFilterUser.toLowerCase())) return false;
      }

      // Filtro por rango de fechas (fecha de préstamo)
      if (_loanFilterDateFrom != null || _loanFilterDateTo != null) {
        try {
          final loanDateStr = l['loanDate'] as String? ?? '';
          if (loanDateStr.isEmpty) return true;
          final loanDate = DateTime.parse(loanDateStr);
          if (_loanFilterDateFrom != null &&
              loanDate.isBefore(_loanFilterDateFrom!))
            return false;
          if (_loanFilterDateTo != null && loanDate.isAfter(_loanFilterDateTo!))
            return false;
        } catch (_) {}
      }

      return true;
    }).toList();

    // Separar los filtrados por estado
    final activos = filtered.where((l) => l['status'] == 'Prestado').toList();
    final devueltos = filtered.where((l) => l['status'] == 'Devuelto').toList();

    return _buildManagementLayout(
      title: 'Préstamos',
      subtitle: 'Gestiona préstamos y devoluciones',
      buttonText: 'Nuevo Préstamo',
      onPressed: _showAddLoanDialog,
      child: Column(
        children: [
          // Panel de filtros
          _buildLoanFiltersPanel(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                //   Sección: Pendientes de devolución
                _buildLoanSectionHeader(
                  icon: Icons.schedule,
                  label: 'Pendientes de devolución',
                  count: activos.length,
                  color: _primaryColor,
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
                //   Sección: Devueltos
                _buildLoanSectionHeader(
                  icon: Icons.check_circle,
                  label: 'Devueltos',
                  count: devueltos.length,
                  color: _primaryColor,
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
          ),
        ],
      ),
    );
  }

  Widget _buildLoanFiltersPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accentColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 12),
          // Fila 1: Estado y Usuario
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _loanFilterStatus,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    isDense: true,
                  ),
                  dropdownColor: _cardColor,
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'activo', child: Text('Activos')),
                    DropdownMenuItem(
                      value: 'devuelto',
                      child: Text('Devueltos'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _loanFilterStatus = v);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar usuario',
                    isDense: true,
                    prefixIcon: Icon(Icons.person_search, size: 18),
                  ),
                  onChanged: (v) {
                    setState(() => _loanFilterUser = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Fila: campos de fecha (readOnly) con showDatePicker tematizado
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _loanDateFromController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Desde',
                    prefixIcon: Icon(Icons.calendar_today),
                    isDense: true,
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _loanFilterDateFrom ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 380),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: _primaryColor,
                                  onPrimary: Colors.white,
                                  surface: _cardColor,
                                  onSurface: _textColor,
                                ),
                                dialogTheme: DialogThemeData(
                                  backgroundColor: _cardColor,
                                ),
                              ),
                              child: child ?? const SizedBox.shrink(),
                            ),
                          ),
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _loanFilterDateFrom = picked;
                        _loanDateFromController.text =
                            '${picked.day}/${picked.month}/${picked.year}';
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _loanDateToController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Hasta',
                    prefixIcon: Icon(Icons.calendar_today),
                    isDense: true,
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _loanFilterDateTo ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 380),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: _primaryColor,
                                  onPrimary: Colors.white,
                                  surface: _cardColor,
                                  onSurface: _textColor,
                                ),
                                dialogTheme: DialogThemeData(
                                  backgroundColor: _cardColor,
                                ),
                              ),
                              child: child ?? const SizedBox.shrink(),
                            ),
                          ),
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _loanFilterDateTo = picked;
                        _loanDateToController.text =
                            '${picked.day}/${picked.month}/${picked.year}';
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Botón Limpiar
              TextButton(
                onPressed: () {
                  setState(() {
                    _loanFilterStatus = 'todos';
                    _loanFilterUser = '';
                    _loanFilterDateFrom = null;
                    _loanFilterDateTo = null;
                    _loanDateFromController.text = '';
                    _loanDateToController.text = '';
                  });
                },
                child: const Text('Limpiar'),
              ),
            ],
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
    final returnDateStr = loan['returnDate'] as String? ?? '';
    final hasReturnDate = returnDateStr.isNotEmpty;
    final returnDate = hasReturnDate
        ? DateTime.tryParse(returnDateStr) ??
              DateTime.now().add(const Duration(days: 15))
        : DateTime.now().add(const Duration(days: 15));
    final now = DateTime.now();
    final isOverdue = returnDate.isBefore(now);
    final daysLeft = returnDate.difference(now).inDays;

    return Container(
      decoration: BoxDecoration(
        color: _itemColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //   Encabezado con estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book, size: 16, color: _primaryColor),
                const SizedBox(width: 6),
                Text(
                  isOverdue
                      ? 'Vencido hace ${-daysLeft} día${-daysLeft == 1 ? '' : 's'}'
                      : daysLeft == 0
                      ? 'Vence hoy'
                      : 'Vence en $daysLeft día${daysLeft == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ACTIVO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          //   Cuerpo
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
                //   Botón claro de devolución
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
        border: Border.all(color: _accentColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: _primaryColor, size: 28),
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
          !_showAvailableOnly || _toInt(book['available']) > 0;

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
            child: _isLoadingBooks
                ? const Center(
                    child: CircularProgressIndicator(color: _primaryColor),
                  )
                : filteredBooks.isEmpty
                ? Center(
                    child: Text(
                      'No se encontraron libros',
                      style: TextStyle(
                        color: _textColor.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: _primaryColor,
                    onRefresh: _loadBooks,
                    child: ListView.separated(
                      itemCount: filteredBooks.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailScreen(
                                  book: book,
                                  librosService: _librosService,
                                ),
                              ),
                            );
                            _loadBooks();
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          color: _textColor.withValues(
                                            alpha: 0.6,
                                          ),
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
                                              color: _textColor.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                              color: _textColor.withValues(
                                                alpha: 0.6,
                                              ),
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
                                    _showDeleteConfirmation(
                                      message:
                                          '¿Eliminar libro "${book['title']}"?',
                                      onConfirm: () async {
                                        try {
                                          await _librosService.deleteLibro(
                                            book['id_libro'],
                                          );
                                          _loadBooks();
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $e'),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    );
                                  },
                                  onEdit: () {
                                    final originalIndex = _books.indexOf(book);
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
          ),
        ],
      ),
    );
  }

  //   Devolución

  void _showReturnLoanDialog(Map<String, dynamic> loan) {
    String condition = 'bueno';
    final observacionesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: _cardColor,
          title: const Text(
            'Registrar Devolución',
            style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${loan['book']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Usuario: ${loan['user']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Condición del libro',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: condition,
                  dropdownColor: _cardColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _itemColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _accentColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'excelente',
                      child: Text('Excelente'),
                    ),
                    DropdownMenuItem(value: 'bueno', child: Text('Bueno')),
                    DropdownMenuItem(value: 'regular', child: Text('Regular')),
                    DropdownMenuItem(value: 'malo', child: Text('Malo')),
                  ],
                  onChanged: (v) => setDialogState(() => condition = v!),
                ),
                const SizedBox(height: 16),
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
                  maxLines: 2,
                  style: const TextStyle(color: _textColor, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Ej: Lomo desgastado...',
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
                  ),
                ),
              ],
            ),
          ),
          actions: _buildDialogActions(
            confirmLabel: 'Confirmar Devolución',
            onConfirm: () async {
              Navigator.pop(ctx);
              try {
                await _librosService.devolverPrestamo(
                  loan['id_prestamo'],
                  observaciones: observacionesController.text,
                );
                _loadLoans();
                _loadBooks();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al devolver: $e')),
                  );
                }
              }
            },
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

  //   Bandeja de Solicitudes

  Widget _buildSolicitudesView() {
    if (_isLoadingSolicitudes) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

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

    final Color statusColor = _primaryColor;
    final String statusText;
    if (isPendiente) {
      statusText = 'PENDIENTE';
    } else if (isAprobada) {
      statusText = 'APROBADA';
    } else {
      statusText = 'RECHAZADA';
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
                  solicitud['fecha'] ?? '',
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
                    statusText,
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
          ElevatedButton.icon(
            onPressed: () => _showSolicitudDetailsDialog(solicitud),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Detalles'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showSolicitudDetailsDialog(Map<String, dynamic> solicitud) {
    final isPendiente = solicitud['estado'] == 'pendiente';
    final isAprobada = solicitud['estado'] == 'aprobada';

    final Color statusColor = _primaryColor;
    final String statusText;
    if (isPendiente) {
      statusText = 'PENDIENTE';
    } else if (isAprobada) {
      statusText = 'APROBADA';
    } else {
      statusText = 'RECHAZADA';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                  Icons.description,
                  color: _primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Detalle de Solicitud',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  _buildDialogInfoRow(Icons.book, solicitud['libro']),
                  const SizedBox(height: 6),
                  _buildDialogInfoRow(
                    Icons.person_outline,
                    solicitud['usuario'],
                  ),
                  const SizedBox(height: 6),
                  _buildDialogInfoRow(
                    Icons.calendar_today,
                    'Fecha: ${solicitud['fecha']}',
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          if (isPendiente)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _rechazarSolicitud(solicitud);
                    },
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Rechazar'),
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
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _aprobarSolicitud(solicitud);
                    },
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Aprobar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textColor,
                  side: BorderSide(color: _textColor.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cerrar'),
              ),
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
          onConfirm: () async {
            Navigator.pop(ctx);
            try {
              await _librosService.updateEstadoSolicitud(
                solicitud['id_solicitud'],
                'aprobada',
              );
              _loadSolicitudes();
              _loadLoans();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Solicitud aprobada'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
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
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _librosService.updateEstadoSolicitud(
                  solicitud['id_solicitud'],
                  'rechazada',
                );
                _loadSolicitudes();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Solicitud rechazada'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Rechazar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
