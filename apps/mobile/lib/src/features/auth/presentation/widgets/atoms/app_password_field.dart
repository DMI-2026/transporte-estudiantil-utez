import 'package:flutter/material.dart';

import 'app_text_field.dart';

/// Campo de contraseña con alternancia para mostrar u ocultar el texto.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.label,
    this.controller,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  var _visible = false;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      key: widget.key,
      label: widget.label,
      controller: widget.controller,
      obscureText: !_visible,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      suffixIcon: IconButton(
        tooltip: _visible ? 'Ocultar contraseña' : 'Mostrar contraseña',
        onPressed: () => setState(() => _visible = !_visible),
        icon: Icon(_visible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
      ),
    );
  }
}