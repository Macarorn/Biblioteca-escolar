import 'package:flutter/material.dart';
import '../widgets/change_password_dialog.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  final String userName;

  const AdminDashboard({super.key, required this.userName});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

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
      'name': 'Carlos Ramírez',
      'role': 'bibliotecario',
      'doc': '3001',
      'email': 'carlos@biblioteca.com',
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

  final List<Map<String, dynamic>> _copies = [
    {
      'code': 'CAS-001',
      'title': 'Cien Años de Soledad',
      'condition': 'excelente',
      'status': 'Disponible',
    },
    {
      'code': 'CAS-002',
      'title': 'Cien Años de Soledad',
      'condition': 'bueno',
      'status': 'Disponible',
    },
    {
      'code': 'CAS-003',
      'title': 'Cien Años de Soledad',
      'condition': 'bueno',
      'status': 'Disponible',
    },
    {
      'code': 'CAS-004',
      'title': 'Cien Años de Soledad',
      'condition': 'regular',
      'status': 'Prestado',
    },
    {
      'code': 'CAS-005',
      'title': 'Cien Años de Soledad',
      'condition': 'excelente',
      'status': 'Prestado',
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
        content = _buildUserManagement(
          textColor,
        ); // assuming these methods exist or I'll stub them
        break;
      case 1:
        content = _buildBulkUpload(textColor);
        break;
      case 2:
        content = _buildBooksManagement(textColor);
        break;
      case 3:
        content = _buildCopiesManagement(textColor);
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

  // Stuubs for build methods if they are complex to fully colorize without seeing code,
  // but I'll try to wrap them or just let them use inherited theme if possible,
  // or just pass textColor.
  // Since I cant see the implementation of _buildUserManagement etc in the read, I will make them accept textColor
  // and locally update them if I can read them.
  // Wait, I read Lines 1-300 of admin_dashboard.dart. I did NOT see _buildUserManagement implementation.
  // It was probably further down.
  // I should probably just update the scaffolding part (Build, Header, Tabs) and assume the content widgets
  // will look okayish or just sit inside the colored container.
  // However, I need to pass `textColor` to them if I want them to look checking.
  // Let's just update the scaffolding first.

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
                const PopupMenuItem(
                  value: 'change_password',
                  child: Row(
                    children: [
                      Icon(Icons.vpn_key_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Cambiar Contraseña'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text('Cerrar Sesión'),
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
            'Masiva',
            Icons.upload_file_outlined,
            textColor,
            primaryColor,
          ), // Shortened name
          _buildTabItem(
            2,
            'Libros',
            Icons.book_outlined,
            textColor,
            primaryColor,
          ),
          _buildTabItem(
            3,
            'Ejemplares',
            Icons.copy_rounded,
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
              Column(
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
              ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.add, size: 18),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D7B68),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
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

  Widget _buildActionButtons(Color textColor) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.edit_outlined, color: textColor.withOpacity(0.5)),
          tooltip: 'Editar',
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          onPressed: () {},
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
      onPressed: () {},
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
                _buildActionButtons(textColor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBulkUpload(Color textColor) {
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
          Text(
            'Carga Masiva desde Excel',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Importa usuarios desde un archivo Excel',
            style: TextStyle(color: textColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),

          // Área de carga
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF9F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: textColor.withOpacity(0.1), width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.upload_file,
                  size: 48,
                  color: textColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Seleccionar archivo Excel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'El archivo debe contener las columnas: Documento, Nombre, Apellido, Email',
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text('Simular Carga (Demo)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D7B68),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pasos del proceso
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proceso de carga:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStepText(
                  '1. El sistema lee los datos del archivo',
                  textColor,
                ),
                _buildStepText('2. Valida la información', textColor),
                _buildStepText(
                  '3. Registra automáticamente los usuarios',
                  textColor,
                ),
                _buildStepText(
                  '4. Crea las credenciales (contraseña = documento)',
                  textColor,
                ),
                _buildStepText('5. Asigna el rol estudiante', textColor),
                _buildStepText('6. Muestra mensaje de éxito', textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepText(String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        height: 1.5,
        color: textColor.withOpacity(0.8),
      ),
    );
  }

  Widget _buildBooksManagement(Color textColor) {
    return _buildManagementLayout(
      title: 'Gestión de Libros',
      subtitle: 'Administra el catálogo de libros',
      buttonText: 'Nuevo Libro',
      onPressed: () {},
      textColor: textColor,
      child: ListView.separated(
        itemCount: _books.length,
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final book = _books[index];
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
                _buildActionButtons(textColor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCopiesManagement(Color textColor) {
    return _buildManagementLayout(
      title: 'Gestión de Ejemplares',
      subtitle: 'Administra los ejemplares físicos',
      buttonText: 'Nuevo Ejemplar',
      onPressed: () {},
      textColor: textColor,
      child: ListView.separated(
        itemCount: _copies.length,
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final copy = _copies[index];
          final isAvailable = copy['status'] == 'Disponible';

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
                      Text(
                        copy['code'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        copy['title'] as String,
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
                              color: textColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: textColor.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              copy['condition'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? const Color(0xFF22C55E)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              copy['status'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(textColor),
              ],
            ),
          );
        },
      ),
    );
  }
}
