import 'dart:ui';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? hintTextStyle;
  final Color? labelColor;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.inputFormatters,
    this.hintTextStyle,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: labelColor ?? AppColors.textMainLight,
                ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              validator: validator,
              onChanged: onChanged,
              maxLines: maxLines,
              inputFormatters: inputFormatters,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF1B2621),
                    fontWeight: FontWeight.w700,
                  ),
              cursorColor: AppColors.primaryDark,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: const Color(0xFFF2F7F4),
                hintStyle: hintTextStyle ??
                    const TextStyle(
                      color: Color(0xFF3E4C45),
                      fontWeight: FontWeight.w700,
                    ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                prefixIcon: prefixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                          color: AppColors.textMainLight.withValues(alpha: 0.8),
                          size: 20,
                        ),
                        child: prefixIcon!,
                      )
                    : null,
                suffixIcon: suffixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                          color: AppColors.textMainLight.withValues(alpha: 0.8),
                          size: 20,
                        ),
                        child: suffixIcon!,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.borderLight.withValues(alpha: 1),
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.borderLight.withValues(alpha: 1),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
