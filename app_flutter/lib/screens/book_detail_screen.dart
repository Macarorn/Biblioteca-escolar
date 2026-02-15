import 'package:flutter/material.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  // Datos simulados para los ejemplares
  final List<Map<String, dynamic>> _copies = [
    {'code': 'CAS-001', 'condition': 'excelente', 'status': 'Disponible'},
    {'code': 'CAS-002', 'condition': 'bueno', 'status': 'Disponible'},
    {'code': 'CAS-003', 'condition': 'bueno', 'status': 'Disponible'},
    {'code': 'CAS-004', 'condition': 'regular', 'status': 'Prestado'},
    {'code': 'CAS-005', 'condition': 'excelente', 'status': 'Prestado'},
  ];

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFFEAE2D7);
    final cardColor = const Color(0xFFF3EFE7);
    final textColor = const Color(0xFF4E342E);
    final primaryColor = const Color(0xFF8D7B68);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalle del Libro',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: textColor),
            onPressed: _showEditBookDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // Confirm removal
            },
          ),
        ],
        titleSpacing: 0,
        backgroundColor: cardColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book['title'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.book['author']} • ${widget.book['category']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Obra maestra del realismo mágico que narra la historia de la familia Buendía.',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ejemplares (${widget.book['available']} de ${widget.book['total']} disponibles)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: primaryColor,
                        ),
                        onPressed: _showAddCopyDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._copies.map(
                    (copy) => _buildCopyItem(
                      copy,
                      cardColor,
                      textColor,
                      primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyItem(
    Map<String, dynamic> copy,
    Color cardColor,
    Color textColor,
    Color primaryColor,
  ) {
    final isAvailable = copy['status'] == 'Disponible';
    final isNotReturned = copy['status'] == 'No Entregado';
    Color statusColor = isAvailable
        ? Colors.green
        : (isNotReturned ? Colors.red : Colors.orange);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy['code'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Condición: ${copy['condition']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.6),
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
                      color: statusColor.withOpacity(0.2),
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
                  if (!isAvailable) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.system_update_alt,
                        color: primaryColor,
                        size: 20,
                      ),
                      tooltip: 'Registrar Devolución',
                      onPressed: () => _showReturnDialog(copy),
                    ),
                  ],
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: textColor.withOpacity(0.5),
                    ),
                    color: cardColor,
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
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          'Editar',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      const PopupMenuItem(
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
        ],
      ),
    );
  }

  void _showReturnDialog(Map<String, dynamic> copy) {
    String newCondition = copy['condition'];
    final cardColor = const Color(0xFFF3EFE7);
    final textColor = const Color(0xFF4E342E);
    final primaryColor = const Color(0xFF8D7B68);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Registrar Devolución', style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccione el estado actual del libro:',
              style: TextStyle(color: textColor.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: newCondition,
              dropdownColor: cardColor,
              decoration: InputDecoration(
                labelText: 'Condición',
                labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: ['excelente', 'bueno', 'regular', 'malo']
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, style: TextStyle(color: textColor)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => newCondition = v!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: textColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                copy['status'] = 'Disponible';
                copy['condition'] = newCondition;
              });
              Navigator.pop(context);
            },
            child: const Text('Confirmar Devolución'),
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
    final cardColor = const Color(0xFFF3EFE7);
    final textColor = const Color(0xFF4E342E);
    final primaryColor = const Color(0xFF8D7B68);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Editar Libro', style: TextStyle(color: textColor)),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: textColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                widget.book['title'] = titleController.text;
                widget.book['author'] = authorController.text;
                widget.book['category'] = categoryController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }

  void _showEditCopyDialog(Map<String, dynamic> copy) {
    final codeController = TextEditingController(text: copy['code']);
    String condition = copy['condition'];
    String status = copy['status'];
    final cardColor = const Color(0xFFF3EFE7);
    final textColor = const Color(0xFF4E342E);
    final primaryColor = const Color(0xFF8D7B68);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Editar Ejemplar', style: TextStyle(color: textColor)),
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
                value: condition,
                dropdownColor: cardColor,
                decoration: const InputDecoration(labelText: 'Condición'),
                items: ['excelente', 'bueno', 'regular', 'malo']
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, style: TextStyle(color: textColor)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => condition = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                dropdownColor: cardColor,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: ['Disponible', 'Prestado', 'No Entregado']
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: TextStyle(color: textColor)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => status = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: textColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                // Adjust counters if status changes
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
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAddCopyDialog() {
    final codeController = TextEditingController(
      text: 'CAS-00${_copies.length + 1}',
    );
    String condition = 'excelente';
    final cardColor = const Color(0xFFF3EFE7);
    final textColor = const Color(0xFF4E342E);
    final primaryColor = const Color(0xFF8D7B68);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Nuevo Ejemplar', style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Código'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: condition,
              dropdownColor: cardColor,
              decoration: const InputDecoration(labelText: 'Condición'),
              items: ['excelente', 'bueno', 'regular', 'malo']
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, style: TextStyle(color: textColor)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => condition = v!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: textColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
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
            child: const Text('Añadir Ejemplar'),
          ),
        ],
      ),
    );
  }
}
