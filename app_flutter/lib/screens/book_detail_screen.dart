import 'package:flutter/material.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  final String userRole;

  const BookDetailScreen({
    super.key,
    required this.book,
    this.userRole = 'administrador',
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  // ── Colores reutilizables ──
  static const _backgroundColor = Color(0xFFEAE2D7);
  static const _cardColor = Color(0xFFF3EFE7);
  static const _textColor = Color(0xFF4E342E);
  static const _primaryColor = Color(0xFF8D7B68);

  // ── Opciones de condición reutilizables ──
  static const _conditionOptions = ['excelente', 'bueno', 'regular', 'malo'];

  bool get _isGestor =>
      widget.userRole == 'administrador' || widget.userRole == 'bibliotecario';

  // Datos simulados para los ejemplares
  final List<Map<String, dynamic>> _copies = [
    {'code': 'CAS-001', 'condition': 'excelente', 'status': 'Disponible'},
    {'code': 'CAS-002', 'condition': 'bueno', 'status': 'Disponible'},
    {'code': 'CAS-003', 'condition': 'bueno', 'status': 'Disponible'},
    {'code': 'CAS-004', 'condition': 'regular', 'status': 'Prestado'},
    {'code': 'CAS-005', 'condition': 'excelente', 'status': 'Prestado'},
  ];

  // ── Helpers para evitar repetición ──

  List<DropdownMenuItem<String>> _buildConditionItems() {
    return _conditionOptions
        .map(
          (c) => DropdownMenuItem(
            value: c,
            child: Text(c, style: const TextStyle(color: _textColor)),
          ),
        )
        .toList();
  }

  List<Widget> _buildDialogActions({
    required VoidCallback onConfirm,
    String confirmLabel = 'Confirmar',
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalle del Libro',
          style: TextStyle(
            color: _textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isGestor) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: _textColor),
              onPressed: _showEditBookDialog,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteBookDialog(),
            ),
          ],
        ],
        titleSpacing: 0,
        backgroundColor: _cardColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.book['author']} • ${widget.book['category']}',
              style: TextStyle(
                fontSize: 14,
                color: _textColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Obra maestra del realismo mágico que narra la historia de la familia Buendía.',
              style: TextStyle(
                fontSize: 14,
                color: _textColor.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ejemplares (${widget.book['available']} de ${widget.book['total']} disponibles)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                if (_isGestor)
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: _primaryColor,
                    ),
                    onPressed: _showAddCopyDialog,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ..._copies.map((copy) => _buildCopyItem(copy)),
            if (!_isGestor && (widget.book['available'] as int) > 0) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _showSolicitarDialog,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Solicitar Préstamo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCopyItem(Map<String, dynamic> copy) {
    final isAvailable = copy['status'] == 'Disponible';
    final isNotReturned = copy['status'] == 'No Entregado';
    final statusColor = isAvailable
        ? Colors.green
        : (isNotReturned ? Colors.red : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy['code'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Condición: ${copy['condition']}',
                style: TextStyle(
                  fontSize: 12,
                  color: _textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  copy['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (_isGestor)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: _textColor.withValues(alpha: 0.5),
                  ),
                  color: _cardColor,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditCopyDialog(copy);
                    } else if (value == 'delete') {
                      setState(() {
                        _copies.remove(copy);
                        if (copy['status'] == 'Disponible') {
                          widget.book['available']--;
                        }
                        widget.book['total']--;
                      });
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Editar',
                        style: TextStyle(color: _textColor),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSolicitarDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor,
        title: const Text(
          'Confirmar Solicitud',
          style: TextStyle(color: _textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Deseas solicitar el préstamo de este libro?',
              style: TextStyle(color: _textColor.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 12),
            Text(
              widget.book['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            Text(
              widget.book['author'],
              style: TextStyle(color: _textColor.withValues(alpha: 0.6)),
            ),
          ],
        ),
        actions: _buildDialogActions(
          confirmLabel: 'Solicitar',
          onConfirm: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solicitud enviada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteBookDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor,
        title: const Text('Confirmar', style: TextStyle(color: _textColor)),
        content: Text('¿Eliminar el libro "${widget.book['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: _textColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Volver al listado
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Libro eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditBookDialog() {
    final titleController = TextEditingController(text: widget.book['title']);
    final authorController = TextEditingController(text: widget.book['author']);
    final categoryController = TextEditingController(
      text: widget.book['category'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: const Text('Editar Libro', style: TextStyle(color: _textColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextFormField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Autor'),
              ),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
            ],
          ),
        ),
        actions: _buildDialogActions(
          confirmLabel: 'Guardar Cambios',
          onConfirm: () {
            setState(() {
              widget.book['title'] = titleController.text;
              widget.book['author'] = authorController.text;
              widget.book['category'] = categoryController.text;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showEditCopyDialog(Map<String, dynamic> copy) {
    final codeController = TextEditingController(text: copy['code']);
    String condition = copy['condition'];
    String status = copy['status'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: const Text(
          'Editar Ejemplar',
          style: TextStyle(color: _textColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Código'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: condition,
                dropdownColor: _cardColor,
                decoration: const InputDecoration(labelText: 'Condición'),
                items: _buildConditionItems(),
                onChanged: (v) => condition = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: status,
                dropdownColor: _cardColor,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: ['Disponible', 'Prestado', 'No Entregado']
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s,
                          style: const TextStyle(color: _textColor),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => status = v!,
              ),
            ],
          ),
        ),
        actions: _buildDialogActions(
          confirmLabel: 'Guardar',
          onConfirm: () {
            setState(() {
              if (copy['status'] == 'Disponible' && status != 'Disponible') {
                widget.book['available']--;
              } else if (copy['status'] != 'Disponible' &&
                  status == 'Disponible') {
                widget.book['available']++;
              }
              copy['code'] = codeController.text;
              copy['condition'] = condition;
              copy['status'] = status;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showAddCopyDialog() {
    final codeController = TextEditingController(
      text: 'CAS-00${_copies.length + 1}',
    );
    String condition = 'excelente';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: const Text(
          'Nuevo Ejemplar',
          style: TextStyle(color: _textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Código'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: condition,
              dropdownColor: _cardColor,
              decoration: const InputDecoration(labelText: 'Condición'),
              items: _buildConditionItems(),
              onChanged: (v) => condition = v!,
            ),
          ],
        ),
        actions: _buildDialogActions(
          confirmLabel: 'Añadir Ejemplar',
          onConfirm: () {
            setState(() {
              _copies.add({
                'code': codeController.text,
                'condition': condition,
                'status': 'Disponible',
              });
              widget.book['available']++;
              widget.book['total']++;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
