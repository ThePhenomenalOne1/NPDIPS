import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/cart_provider.dart';

class GlassSummaryCard extends StatelessWidget {
  const GlassSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Price",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSubLight,
                  ),
                ),
                Consumer<CartProvider>(
                  builder: (context, cart, _) => Text(
                    "\$${cart.total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: "Checkout Now",
              onPressed: () {
                context.push('/checkout');
              },
            ),
          ],
        ),
      ),
    );
  }
}
