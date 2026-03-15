import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/services/fib_payment_service.dart';
import 'package:dipstore_ui/core/widgets/custom_button.dart';
import '../../core/providers/cart_provider.dart';
import 'dialogs/fib_payment_dialog.dart';
import 'dialogs/nass_payment_dialog.dart';

import 'package:dipstore_ui/features/cart/models/cart_item_model.dart';

class CheckoutScreen extends StatefulWidget {
  final CartItemModel? singleItem;
  final String? storeId;
  final String? storeName;

  const CheckoutScreen({
    super.key,
    this.singleItem,
    this.storeId,
    this.storeName,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedPaymentMethod;
  bool _isPreparingFibPayment = false;
  final FibPaymentService _fibPaymentService = const FibPaymentService();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate totals based on context (Single Item vs Store Cart)
    double subtotal = 0.0;
    if (widget.singleItem != null) {
      subtotal = widget.singleItem!.total;
    } else if (widget.storeId != null) {
      subtotal = cart.getSubtotal(widget.storeId!);
    }

    final double tax = subtotal * 0.05;
    final double total = subtotal + tax + 5.0; // 5.0 delivery fee

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.storeName != null
              ? "Checkout: ${widget.storeName}"
              : "Checkout",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Section
            Text(
              "Order Summary",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildOrderSummary(context, subtotal, tax, total),
            const SizedBox(height: 32),

            // Payment Method Section
            Text(
              "Choose Payment Method",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodOption(
              context: context,
              title: "FIB (First Iraqi Bank)",
              subtitle: "Pay securely with your FIB account",
              icon: Icons.account_balance,
              value: "fib",
              groupValue: _selectedPaymentMethod,
              onChanged: (val) => setState(() => _selectedPaymentMethod = val),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodOption(
              context: context,
              title: "NASS Wallet",
              subtitle: "Pay with NASS digital wallet",
              icon: Icons.account_balance_wallet,
              value: "nass",
              groupValue: _selectedPaymentMethod,
              onChanged: (val) => setState(() => _selectedPaymentMethod = val),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodOption(
              context: context,
              title: "Cash on Delivery",
              subtitle: "Pay when you receive your order",
              icon: Icons.local_shipping,
              value: "cash",
              groupValue: _selectedPaymentMethod,
              onChanged: (val) => setState(() => _selectedPaymentMethod = val),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSubDark
                          : AppColors.textSubLight,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isPreparingFibPayment
                    ? "Preparing FIB Payment..."
                    : "Proceed to Payment ✅",
                isLoading: _isPreparingFibPayment,
                onPressed: _selectedPaymentMethod == null || _isPreparingFibPayment
                    ? null
                    : () => _handlePayment(context, total, subtotal, tax),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    double subtotal,
    double tax,
    double total,
  ) {
    // ignore: unused_local_variable
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const deliveryFee = 5.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
          const SizedBox(height: 12),
          _buildSummaryRow("Tax (5%)", "\$${tax.toStringAsFixed(2)}"),
          const SizedBox(height: 12),
          _buildSummaryRow(
            "Delivery Fee",
            "\$${deliveryFee.toStringAsFixed(2)}",
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildSummaryRow(
            "Total",
            "\$${total.toStringAsFixed(2)}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  static Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? null : AppColors.textSubLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.bgDark : AppColors.bgLight),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSubLight,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSubDark
                          : AppColors.textSubLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment(
    BuildContext context,
    double total,
    double subtotal,
    double tax,
  ) async {
    // Handle different payment methods
    if (_selectedPaymentMethod == 'fib') {
      await _startFibPayment(total);
    } else if (_selectedPaymentMethod == 'nass') {
      showNassPaymentDialog(
        context: context,
        amount: total,
        onConfirm: () => _completeOrder(context, total),
        onCancel: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment cancelled')),
          );
        },
      );
    } else if (_selectedPaymentMethod == 'cash') {
      _completeOrder(context, total);
    }
  }

  Future<void> _startFibPayment(double total) async {
    setState(() => _isPreparingFibPayment = true);

    try {
      final paymentSession = await _fibPaymentService.createPayment(
        amount: total,
        description: _buildFibPaymentDescription(),
      );

      if (!mounted) {
        return;
      }

      setState(() => _isPreparingFibPayment = false);

      await showFibPaymentDialog(
        context: context,
        amount: total,
        paymentSession: paymentSession,
        onConfirm: () async {
          final status = await _fibPaymentService.checkPaymentStatus(
            paymentSession.paymentId,
          );

          if (!mounted) {
            return false;
          }

          if (status.toUpperCase() == 'PAID') {
            _completeOrder(context, total);
            return true;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment status is currently $status. Complete the payment in FIB, then verify again.'),
            ),
          );
          return false;
        },
        onCancel: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment cancelled')),
          );
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isPreparingFibPayment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  String _buildFibPaymentDescription() {
    if (widget.singleItem != null) {
      return 'DipStore order for ${widget.singleItem!.title}';
    }

    if (widget.storeName != null && widget.storeName!.trim().isNotEmpty) {
      return 'DipStore checkout for ${widget.storeName!.trim()}';
    }

    return 'DipStore Checkout';
  }

  void _completeOrder(BuildContext context, double total) async {
    // Show completion sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              "Order Placed Successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Thank you for your order. Your items will be delivered shortly.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSubLight, fontSize: 16),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: "Back to Home",
              onPressed: () {
                final cart = context.read<CartProvider>();
                final paymentMethodName = _selectedPaymentMethod == 'fib'
                    ? 'FIB (First Iraqi Bank)'
                    : _selectedPaymentMethod == 'nass'
                        ? 'NASS Wallet'
                        : 'Cash on Delivery';

                if (widget.singleItem != null) {
                  cart.addOrder(
                    widget.singleItem!,
                    paymentMethod: paymentMethodName,
                  );
                } else if (widget.storeId != null) {
                  // Get all items for this store
                  final storeItems = cart.getItemsForStore(widget.storeId!);
                  for (var item in storeItems) {
                    cart.addOrder(item, paymentMethod: paymentMethodName);
                  }
                  // Clear ONLY this store's cart
                  cart.clearCart(widget.storeId!);
                }
                context.go('/shell');
              },
            ),
          ],
        ),
      ),
    );
  }
}
