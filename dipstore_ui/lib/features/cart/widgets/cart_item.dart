import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';

class CartItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final double price;
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;
  final String? imageUrl;
  final VoidCallback? onTap;
  final DateTime? timestamp;
  final String? status;

  const CartItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
    this.imageUrl,
    this.onTap,
    this.timestamp,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: AppTheme.elevation1,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.shopping_bag_outlined,
                                color: AppColors.textSubLight),
                      )
                    : const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.textSubLight,
                      ),
              ),
            ),
            const SizedBox(width: AppTheme.spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSubLight,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "\$${price.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      if (status != null) ...[
                        const SizedBox(width: 8),
                        _buildStatusBadge(context, status!),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            if (onIncrement != null && onDecrement != null)
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Column(
                      children: [
                        _buildIconButton(
                          icon: Icons.add_rounded,
                          onPressed: onIncrement!,
                        ),
                        Text(
                          "$quantity",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        _buildIconButton(
                          icon: Icons.remove_rounded,
                          onPressed: onDecrement!,
                        ),
                      ],
                    ),
                  ),
                  if (onRemove != null) 
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              )
            else if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  _getTimeAgo(timestamp!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSubLight,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppTheme.radiusS),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 16, color: AppColors.textMainLight),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusXS),
      ),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSubLight;
    }
  }

  String _getTimeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inMinutes < 1) return "just now";
    if (duration.inMinutes < 60) return "${duration.inMinutes}m ago";
    if (duration.inHours < 24) return "${duration.inHours}h ago";
    return "${duration.inDays}d ago";
  }
}
