import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';

class GlassProfileCard extends StatelessWidget {
  const GlassProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    // ... same provider logic ...
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.elevation2,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.startsWith('http'))
                      ? NetworkImage(user.avatarUrl!) as ImageProvider
                      : (user?.avatarUrl != null)
                          ? AssetImage(user!.avatarUrl!)
                          : const NetworkImage(
                              'https://ui-avatars.com/api/?name=User&background=10b981&color=fff',
                            ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? "Guest User",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? "Welcome to KRD Hub",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSubLight,
                      ),
                ),
                if (user != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
