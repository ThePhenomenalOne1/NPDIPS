import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import '../../core/providers/cart_provider.dart';
import 'package:go_router/go_router.dart';
import 'models/order_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders"),
      ),
      body: const _YourOrdersView(),
    );
  }
}

class _YourOrdersView extends StatelessWidget {
  const _YourOrdersView();

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final groups = _groupOrdersByStore(cart.orderedItems);

        if (groups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 72,
                  color: AppColors.textSubLight.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppTheme.spacing),
                Text(
                  "No orders yet",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textSubLight,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  "Completed orders from each store will appear here.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSubLight,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacing,
            AppTheme.spacingM,
            AppTheme.spacing,
            AppTheme.spacingXXL,
          ),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];

            return Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.14),
                    AppColors.surfaceLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                boxShadow: AppTheme.elevation2,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.push(
                      '/store-orders-details',
                      extra: {
                        'storeName': group.storeName,
                        'orders': group.orders,
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusM,
                                ),
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.storeName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Last order ${_formatRelative(group.latestOrderAt)}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSubLight,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSubLight,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing),
                        Wrap(
                          spacing: AppTheme.spacingS,
                          runSpacing: AppTheme.spacingS,
                          children: [
                            _MetricChip(
                              icon: Icons.receipt_long_outlined,
                              label: "${group.orders.length} orders",
                            ),
                            _MetricChip(
                              icon: Icons.inventory_2_outlined,
                              label: "${group.totalItems} items",
                            ),
                            _MetricChip(
                              icon: Icons.payments_outlined,
                              label: "\$${group.totalSpent.toStringAsFixed(2)}",
                              valueColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

List<_StoreOrderGroup> _groupOrdersByStore(List<OrderModel> orders) {
  final Map<String, List<OrderModel>> grouped = {};

  for (final order in orders) {
    grouped.putIfAbsent(order.businessName, () => []).add(order);
  }

  final groups = grouped.entries.map((entry) {
    final storeOrders = [...entry.value]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final totalItems = storeOrders.fold<int>(0, (sum, order) => sum + order.quantity);
    final totalSpent = storeOrders.fold<double>(
      0,
      (sum, order) => sum + (order.price * order.quantity),
    );

    return _StoreOrderGroup(
      storeName: entry.key,
      orders: storeOrders,
      latestOrderAt: storeOrders.first.timestamp,
      totalItems: totalItems,
      totalSpent: totalSpent,
    );
  }).toList()
    ..sort((a, b) => b.latestOrderAt.compareTo(a.latestOrderAt));

  return groups;
}

String _formatRelative(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);

  if (diff.inMinutes < 1) return "just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
  if (diff.inHours < 24) return "${diff.inHours}h ago";
  if (diff.inDays < 7) return "${diff.inDays}d ago";

  return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? valueColor;

  const _MetricChip({
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
        color: AppColors.surfaceLight.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.5),
        ),
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

class _StoreOrderGroup {
  final String storeName;
  final List<OrderModel> orders;
  final DateTime latestOrderAt;
  final int totalItems;
  final double totalSpent;

  const _StoreOrderGroup({
    required this.storeName,
    required this.orders,
    required this.latestOrderAt,
    required this.totalItems,
    required this.totalSpent,
  });
}
