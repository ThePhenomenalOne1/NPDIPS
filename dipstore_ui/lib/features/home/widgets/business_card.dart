import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dipstore_ui/core/utils/icon_utils.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';

// NEW: BusinessCard Widget for Dashboard
class BusinessCard extends StatelessWidget {
  final String id;
  final String name;
  final String category;
  final String tagline;
  final String about;
  final String? imageUrl;
  final String? phoneNumber;

  const BusinessCard({
    super.key,
    required this.id,
    required this.name,
    required this.category,
    required this.tagline,
    required this.about,
    this.imageUrl,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/business-details',
        extra: {
          'storeId': id,
          'name': name,
          'category': category,
          'tagline': tagline,
          'about': about,
          'imageUrl': imageUrl,
          'phoneNumber': phoneNumber,
        },
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(
          right: AppTheme.spacing,
          bottom: 8, // Keep for shadow space
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: AppTheme.elevation1,
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusL),
                ),
                child: Container(
                  width: double.infinity,
                  color: AppColors.bgLight,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildIconFallback(context);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              );
                          },
                        )
                      : _buildIconFallback(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        getBusinessIcon(category),
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSubLight,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconFallback(BuildContext context) {
    return Center(
      child: Icon(
        getBusinessIcon(category),
        size: 40,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }
}
