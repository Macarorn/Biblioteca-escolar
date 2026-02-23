import 'package:flutter/material.dart';

class ChangePasswordDialog extends StatefulWidget {
  final bool isMandatory;

  const ChangePasswordDialog({super.key, this.isMandatory = false});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  // ── Colores reutilizables (misma paleta de la app) ──
  static const _cardColor = Color(0xFFF3EFE7);
  static const _primaryColor = Color(0xFF8D7B68);
  static const _textColor = Color(0xFF4E342E);
  static const _inputFillColor = Color(0xFFFAF9F6);

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.isMandatory
                        ? 'Cambio de contraseña obligatorio'
                        : 'Cambiar Contraseña',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                ),
                if (!widget.isMandatory)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: _textColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.isMandatory
                  ? 'Por seguridad, debe cambiar su contraseña en el primer ingreso.'
                  : 'Ingrese su nueva contraseña.',
              style: TextStyle(color: _textColor.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            Text(
              'Nueva Contraseña',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: _textColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                hintText: 'Ingrese nueva contraseña',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: _inputFillColor,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: _primaryColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Confirmar Contraseña',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: _textColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                hintText: 'Confirme la contraseña',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: _inputFillColor,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: _primaryColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _error,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final newPass = _newPasswordController.text.trim();
                  final confirmPass = _confirmPasswordController.text.trim();

                  if (newPass.isEmpty || confirmPass.isEmpty) {
                    setState(() => _error = 'Complete ambos campos');
                    return;
                  }
                  if (newPass.length < 6) {
                    setState(() => _error = 'Mínimo 6 caracteres');
                    return;
                  }
                  if (newPass != confirmPass) {
                    setState(() => _error = 'Las contraseñas no coinciden');
                    return;
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contraseña cambiada correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Cambiar Contraseña',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
