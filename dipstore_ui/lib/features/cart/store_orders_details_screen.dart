import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';
import 'package:dipstore_ui/features/cart/models/order_model.dart';
import 'package:flutter/material.dart';

class StoreOrdersDetailsScreen extends StatelessWidget {
  final String storeName;
  final List<OrderModel> orders;

  const StoreOrdersDetailsScreen({
    super.key,
    required this.storeName,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final sortedOrders = [...orders]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final totalItems = sortedOrders.fold<int>(
      0,
      (sum, order) => sum + order.quantity,
    );
    final totalSpent = sortedOrders.fold<double>(
      0,
      (sum, order) => sum + (order.price * order.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(storeName),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacing,
          AppTheme.spacingM,
          AppTheme.spacing,
          AppTheme.spacingXXL,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.16),
                  AppColors.surfaceLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Wrap(
              spacing: AppTheme.spacingS,
              runSpacing: AppTheme.spacingS,
              children: [
                _SummaryPill(
                  icon: Icons.receipt_long_outlined,
                  label: "${sortedOrders.length} orders",
                ),
                _SummaryPill(
                  icon: Icons.inventory_2_outlined,
                  label: "$totalItems items",
                ),
                _SummaryPill(
                  icon: Icons.payments_outlined,
                  label: "\$${totalSpent.toStringAsFixed(2)}",
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing),
          ...sortedOrders.map(
            (order) => Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
              padding: const EdgeInsets.all(AppTheme.spacing),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.elevation1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: AppColors.bgLight,
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          child: order.imageUrl != null &&
                                  order.imageUrl!.isNotEmpty
                              ? Image.network(
                                  order.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: AppColors.textSubLight,
                                  ),
                                )
                              : const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: AppColors.textSubLight,
                                ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.productName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.productSubtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSubLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusChip(status: order.status),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing),
                  Row(
                    children: [
                      _InfoText(label: "Order", value: order.orderId),
                      const SizedBox(width: AppTheme.spacing),
                      _InfoText(label: "Qty", value: "x${order.quantity}"),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    children: [
                      _InfoText(label: "Date", value: _formatDate(order.timestamp)),
                      const SizedBox(width: AppTheme.spacing),
                      _InfoText(label: "Payment", value: order.paymentMethod),
                    ],
                  ),
                  const Divider(height: AppTheme.spacingL),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSubLight,
                        ),
                      ),
                      Text(
                        "\$${(order.price * order.quantity).toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? valueColor;

  const _SummaryPill({
    required this.icon,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.65)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSubLight),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: valueColor ?? AppColors.textMainLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  final String label;
  final String value;

  const _InfoText({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Text.rich(
        TextSpan(
          text: "$label: ",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSubLight,
          ),
          children: [
            TextSpan(
              text: value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMainLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color _colorForStatus(OrderStatus status) {
  switch (status) {
    case OrderStatus.completed:
      return AppColors.success;
    case OrderStatus.pending:
      return AppColors.warning;
    case OrderStatus.cancelled:
      return AppColors.error;
  }
}

String _formatDate(DateTime dateTime) {
  final d = dateTime.day.toString().padLeft(2, "0");
  final m = dateTime.month.toString().padLeft(2, "0");
  final y = dateTime.year.toString();
  final hh = dateTime.hour.toString().padLeft(2, "0");
  final mm = dateTime.minute.toString().padLeft(2, "0");
  return "$d/$m/$y  $hh:$mm";
}
