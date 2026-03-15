import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dipstore_ui/core/providers/cart_provider.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';
import 'package:dipstore_ui/features/cart/widgets/cart_item.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: false,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final orders = cart.orderedItems;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: AppColors.borderLight),
                  const SizedBox(height: AppTheme.spacing),
                  Text(
                    "No orders yet",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSubLight,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = cart.orderedItems[index];
              return CartItem(
                title: order.productName,
                subtitle: "${order.businessName} • ${order.productSubtitle}",
                price: order.price,
                quantity: order.quantity,
                imageUrl: order.imageUrl,
                timestamp: order.timestamp,
                status: order.status.name, // Convert enum to string
                onTap: () {
                  // Navigate to details if needed
                },
              );
            },
          );
        },
      ),
    );
  }
}
