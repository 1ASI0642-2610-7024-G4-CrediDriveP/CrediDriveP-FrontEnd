import 'package:flutter/material.dart';

/// Campo de texto con tooltip de ayuda contextual + validación en tiempo real.
///
/// Cubre los campos críticos del Cap 5 (TEA, periodo de gracia, monto, etc.)
/// con ícono `help_outline` que despliega un mensaje de ayuda al tocar.
class HelpField extends StatelessWidget {
  final String label;
  final String helpMessage;
  final String? helperExample;
  final String? errorText;
  final String? suffix;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final bool obscureText;

  const HelpField({
    super.key,
    required this.label,
    required this.helpMessage,
    required this.controller,
    required this.onChanged,
    this.helperExample,
    this.errorText,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperExample,
          errorText: errorText,
          suffixText: suffix,
          border: const OutlineInputBorder(),
          suffixIcon: Tooltip(
            message: helpMessage,
            triggerMode: TooltipTriggerMode.tap,
            showDuration: const Duration(seconds: 6),
            child: const Icon(Icons.help_outline, color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }
}

class HelpDropdown<T> extends StatelessWidget {
  final String label;
  final String helpMessage;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? errorText;

  const HelpDropdown({
    super.key,
    required this.label,
    required this.helpMessage,
    required this.value,
    required this.items,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
          suffixIcon: Tooltip(
            message: helpMessage,
            triggerMode: TooltipTriggerMode.tap,
            showDuration: const Duration(seconds: 6),
            child: const Icon(Icons.help_outline, color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }
}
