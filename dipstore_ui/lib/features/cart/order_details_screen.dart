// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'models/order_model.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header Information
            _buildSectionTitle(context, "Order Info"),
            const SizedBox(height: 12),
            _buildInfoCard(context, [
              _buildDetailRow("Order ID", order.orderId, isBold: true),
              _buildDetailRow(
                "Status",
                order.status.name.toUpperCase(),
                valueColor: _getStatusColor(order.status),
              ),
              _buildDetailRow("Date", _formatDate(order.timestamp)),
              _buildDetailRow("Payment", order.paymentMethod),
            ]),

            const SizedBox(height: 32),

            // Product Information
            _buildSectionTitle(context, "Item Details"),
            const SizedBox(height: 12),
            _buildInfoCard(context, [
              Row(
                children: [
                  if (order.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        order.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          order.businessName,
                          style: const TextStyle(
                            color: AppColors.textSubLight,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(),
              ),
              _buildDetailRow("Quantity", "x${order.quantity}"),
              _buildDetailRow(
                "Price per item",
                "\$${order.price.toStringAsFixed(2)}",
              ),
              _buildDetailRow(
                "Total Amount",
                "\$${(order.price * order.quantity).toStringAsFixed(2)}",
                isBold: true,
              ),
            ]),

            const SizedBox(height: 32),

            // Timeline / Status Progress
            _buildSectionTitle(context, "Order Timeline"),
            const SizedBox(height: 12),
            _buildTimeline(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSubLight)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Column(
      children: [
        _buildTimelineTile(
          context,
          "Order Placed",
          _formatDate(order.timestamp),
          isCompleted: true,
        ),
        _buildTimelineTile(
          context,
          "Processing",
          "In progress",
          isCurrent: true,
        ),
        _buildTimelineTile(context, "Shipped", "Waiting...", isLast: true),
      ],
    );
  }

  Widget _buildTimelineTile(
    BuildContext context,
    String title,
    String subtitle, {
    bool isCompleted = false,
    bool isCurrent = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.primary
                    : (isCurrent ? Colors.orange : Colors.grey[300]),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.primary : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCurrent || isCompleted ? null : Colors.grey,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: AppColors.textSubLight),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
