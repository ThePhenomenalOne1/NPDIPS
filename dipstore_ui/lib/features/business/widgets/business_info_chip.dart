import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';

class BusinessInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isStar;

  const BusinessInfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.isStar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: isStar ? Colors.amber : AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ],
    );
  }
}
