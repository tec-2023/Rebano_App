import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? helperText;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.helperText,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscure = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget? effectiveSuffixIcon = widget.suffixIcon;

    if (widget.obscureText && widget.suffixIcon == null) {
      effectiveSuffixIcon = IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          size: 21,
        ),
        splashRadius: 20,
        tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
        onPressed: () {
          setState(() {
            _obscure = !_obscure;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 22) : null,
            suffixIcon: effectiveSuffixIcon,
          ),
        ),
      ],
    );
  }
}
