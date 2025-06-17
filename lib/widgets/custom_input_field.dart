import 'package:flutter/material.dart';
import 'package:mone/core/theme/app_color.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final Function(String)? onChanged;
  final bool isBordered;
  final bool isEnabled;
  final String? prefixText;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.isBordered = true,
    this.isEnabled = true,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      enabled: isEnabled,
      style: TextStyle(
        color:
            isEnabled
                ? null
                : Theme.of(
                  context,
                ).colorScheme.onSurface, // Override disabled text color
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle:
            isEnabled
                ? null
                : TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ), // Override disabled label color
        prefixText: prefixText,
        prefixStyle: TextStyle(
          color:
              isEnabled
                  ? null
                  : Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant, // Override disabled prefix text color
        ),
        prefixIcon: Icon(
          prefixIcon,
          color:
              isEnabled
                  ? null
                  : Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant, // Override disabled icon color
        ),
        suffixIcon: suffixIcon,
        border:
            isBordered
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
                : OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
        enabledBorder:
            isBordered
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
                : OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
        disabledBorder:
            isBordered
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
                : OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
        focusedBorder:
            isBordered
                ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                )
                : OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
        filled: true,
        fillColor: AppColors.containerSurface(context),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
