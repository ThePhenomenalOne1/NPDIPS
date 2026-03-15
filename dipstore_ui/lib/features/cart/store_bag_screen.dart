import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/widgets/custom_button.dart';
import '../../core/providers/cart_provider.dart';
import 'widgets/cart_item.dart';

class StoreBagScreen extends StatelessWidget {
  final String storeId;
  final String storeName;

  const StoreBagScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(storeName),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final items = cart.getItemsForStore(storeId);

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: AppColors.borderLight,
                  ),
                  const SizedBox(height: AppTheme.spacing),
                  Text(
                    "Your bag is empty",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textSubLight,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  CustomButton(
                    text: "Start Shopping",
                    width: 200,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppTheme.spacing),
                  itemCount: items.length,
                  separatorBuilder: (ctx, i) =>
                      const SizedBox(height: AppTheme.spacing),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CartItem(
                      title: item.title,
                      subtitle: item.subtitle,
                      price: item.price,
                      quantity: item.quantity,
                      imageUrl: item.imageUrl,
                      onIncrement: () =>
                          cart.incrementQuantity(item.id, storeId),
                      onDecrement: () =>
                          cart.decrementQuantity(item.id, storeId),
                      onRemove: () => cart.removeItem(item.id, storeId),
                    );
                  },
                ),
              ),

              // Bottom Summary Section
              Container(
                margin: const EdgeInsets.all(AppTheme.spacing),
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: AppTheme.elevation2,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSummaryRow(
                        context,
                        "Subtotal",
                        "\$${cart.getSubtotal(storeId).toStringAsFixed(2)}",
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildSummaryRow(
                        context,
                        "Service Fee (5%)",
                        "\$${(cart.getSubtotal(storeId) * 0.05).toStringAsFixed(2)}",
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppTheme.spacing),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order Total",
                            style:
                                Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            "\$${cart.getTotal(storeId).toStringAsFixed(2)}",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      CustomButton(
                        text: "Place Order for $storeName",
                        onPressed: () {
                          context.push(
                            '/checkout',
                            extra: {
                              'storeId': storeId,
                              'storeName': storeName
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSubLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
