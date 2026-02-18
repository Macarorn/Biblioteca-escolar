import 'package:flutter/material.dart';
import '../services/libros_service.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  final String userRole;
  final LibrosService? librosService;

  const BookDetailScreen({
    super.key,
    required this.book,
    this.userRole = 'administrador',
    this.librosService,
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

  // Datos cargados desde API
  List<Map<String, dynamic>> _copies = [];
  bool _isLoading = true;
  int _available = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _available = widget.book['available'] ?? 0;
    _total = widget.book['total'] ?? 0;
    _loadCopies();
  }

  Future<void> _loadCopies() async {
    final service = widget.librosService;
    if (service == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final libroId = widget.book['id_libro'];
      if (libroId == null) {
        setState(() => _isLoading = false);
        return;
      }
      final ejemplares = await service.getEjemplares(libroId);
      final disp = await service.getDisponibilidad(libroId);
      if (mounted) {
        setState(() {
          _copies = ejemplares
              .map(
                (e) => <String, dynamic>{
                  ...e,
                  'code': e['codigo_ejemplar'] ?? '',
                  'condition': e['condicion_fisica'] ?? '',
                  'status': _mapDisponibilidad(e['disponibilidad']),
                },
              )
              .toList();
          _available = disp['disponibles'] ?? 0;
          _total = disp['total'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapDisponibilidad(String? disp) {
    switch (disp) {
      case 'disponible':
        return 'Disponible';
      case 'prestado':
        return 'Prestado';
      case 'mantenimiento':
        return 'En Mantenimiento';
      default:
        return disp ?? '';
    }
  }

  String _reverseMapDisponibilidad(String status) {
    switch (status) {
      case 'Disponible':
        return 'disponible';
      case 'Prestado':
        return 'prestado';
      case 'Mantenimiento':
      case 'En Mantenimiento':
        return 'mantenimiento';
      default:
        return 'disponible';
    }
  }

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
                  'Ejemplares ($_available de $_total disponibles)',
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
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: _primaryColor),
              )
            else
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
    final isMaintenance = copy['status'] == 'En Mantenimiento';
    final statusColor = isAvailable
        ? Colors.green
        : (isMaintenance ? Colors.orange : Colors.orange);

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
                  onSelected: (value) async {
                    if (value == 'edit') {
                      _showEditCopyDialog(copy);
                    } else if (value == 'delete') {
                      final service = widget.librosService;
                      if (service != null && copy['id_ejemplar'] != null) {
                        try {
                          await service.deleteEjemplar(copy['id_ejemplar']);
                          _loadCopies();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      } else {
                        setState(() {
                          _copies.remove(copy);
                        });
                      }
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
            onPressed: () async {
              Navigator.pop(ctx);
              final service = widget.librosService;
              if (service != null && widget.book['id_libro'] != null) {
                try {
                  await service.deleteLibro(widget.book['id_libro']);
                  if (mounted) Navigator.pop(context, true);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al eliminar: $e')),
                    );
                  }
                }
              } else {
                Navigator.pop(context);
              }
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
          onConfirm: () async {
            Navigator.pop(context);
            final service = widget.librosService;
            if (service != null && widget.book['id_libro'] != null) {
              try {
                await service.updateLibro(widget.book['id_libro'], {
                  'codigo_libro': widget.book['codigo_libro'] ?? '',
                  'titulo': titleController.text,
                  'autor': authorController.text,
                  'area': categoryController.text,
                  'anio_publicacion': widget.book['anio_publicacion'],
                  'estado': widget.book['estado'] ?? 'activo',
                });
                setState(() {
                  widget.book['title'] = titleController.text;
                  widget.book['author'] = authorController.text;
                  widget.book['category'] = categoryController.text;
                  widget.book['titulo'] = titleController.text;
                  widget.book['autor'] = authorController.text;
                  widget.book['area'] = categoryController.text;
                });
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            } else {
              setState(() {
                widget.book['title'] = titleController.text;
                widget.book['author'] = authorController.text;
                widget.book['category'] = categoryController.text;
              });
            }
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
                items: ['Disponible', 'Prestado', 'En Mantenimiento']
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
          onConfirm: () async {
            Navigator.pop(context);
            final service = widget.librosService;
            if (service != null && copy['id_ejemplar'] != null) {
              try {
                await service.updateEjemplar(copy['id_ejemplar'], {
                  'id_libro': widget.book['id_libro'],
                  'codigo_ejemplar': codeController.text,
                  'condicion_fisica': condition,
                  'disponibilidad': _reverseMapDisponibilidad(status),
                });
                _loadCopies();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            } else {
              setState(() {
                copy['code'] = codeController.text;
                copy['condition'] = condition;
                copy['status'] = status;
              });
            }
          },
        ),
      ),
    );
  }

  void _showAddCopyDialog() {
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
          onConfirm: () async {
            Navigator.pop(context);
            final service = widget.librosService;
            if (service != null && widget.book['id_libro'] != null) {
              try {
                await service.createEjemplar({
                  'id_libro': widget.book['id_libro'],
                  'condicion_fisica': condition,
                  'disponibilidad': 'disponible',
                });
                _loadCopies();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            } else {
              setState(() {
                _copies.add({'condition': condition, 'status': 'Disponible'});
              });
            }
          },
        ),
      ),
    );
  }
}
