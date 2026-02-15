import 'package:flutter/material.dart';
import '../widgets/change_password_dialog.dart';
import 'login_screen.dart';

class LibrarianDashboard extends StatefulWidget {
  final String userName;

  const LibrarianDashboard({super.key, required this.userName});

  @override
  State<LibrarianDashboard> createState() => _LibrarianDashboardState();
}

class _LibrarianDashboardState extends State<LibrarianDashboard> {
  int _selectedIndex = 0;

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
                  'Panel Bibliotecario',
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
            'Solicitudes',
            Icons.description_outlined,
            textColor,
            primaryColor,
          ),
          _buildTabItem(
            1,
            'Préstamos',
            Icons.local_library_outlined,
            textColor,
            primaryColor,
          ),
          _buildTabItem(2, 'Historial', Icons.history, textColor, primaryColor),
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
              if (MediaQuery.of(context).size.width > 350) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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

  Widget _buildContent(Color textColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(textColor),
          const SizedBox(height: 40),
          _buildEmptyState(textColor),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(Color textColor) {
    String title = 'Solicitudes Pendientes';
    String subtitle = 'Revisa y aprueba o rechaza';

    if (_selectedIndex == 1) {
      title = 'Préstamos Activos';
      subtitle = 'Registra devoluciones';
    } else if (_selectedIndex == 2) {
      title = 'Historial';
      subtitle = 'Todos los préstamos completados';
    }

    return Column(
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
        Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildEmptyState(Color textColor) {
    String message = 'No hay solicitudes pendientes';
    if (_selectedIndex == 1) message = 'No hay préstamos activos';
    if (_selectedIndex == 2) message = 'No hay historial';

    return Expanded(
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
