import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget? trailing;
  final bool hideArrow;
  final VoidCallback? onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.trailing,
    this.hideArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacing,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppTheme.spacing),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
              if (!hideArrow)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
