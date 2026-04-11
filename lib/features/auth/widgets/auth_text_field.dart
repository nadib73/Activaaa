import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final bool isValid;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
    this.isValid = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          style: const TextStyle(color: AppColors.textDark, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(
              widget.prefixIcon,
              color: widget.isValid ? AppColors.teal : Colors.grey.shade400,
              size: 18,
            ),
            suffixIcon: _buildSuffix(),
            filled: true,
            fillColor: AppColors.bgWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isValid ? AppColors.teal : Colors.grey.shade200,
                width: widget.isValid ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffix() {
    if (widget.isPassword) {
      return GestureDetector(
        onTap: () => setState(() => _obscure = !_obscure),
        child: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.grey.shade400,
          size: 18,
        ),
      );
    }
    if (widget.isValid) {
      return const Icon(
        Icons.check_circle_outline_rounded,
        color: AppColors.teal,
        size: 18,
      );
    }
    return null;
  }
}
