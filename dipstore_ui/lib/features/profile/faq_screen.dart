import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        "q": "How do I track my order?",
        "a":
            "You can track your order in the 'My Orders' section. Once shipped, you'll see a tracking number.",
      },
      {
        "q": "What payment methods do you accept?",
        "a":
            "We accept all major credit cards (Visa, MasterCard), PayPal, and Cash on Delivery for select locations.",
      },
      {
        "q": "Can I return an item?",
        "a":
            "Yes, we accept returns within 14 days of delivery. Items must be unused and in original packaging.",
      },
      {
        "q": "How can I contact support?",
        "a":
            "You can reach us at support@dipstore.com or call our hotline at 1-800-DIPSTORE.",
      },
      {
        "q": "Is my data safe?",
        "a":
            "Yes, we use industry-standard encryption to protect your personal information and payment details.",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final item = faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ExpansionTile(
              leading: Icon(Icons.help_outline, color: AppColors.primary),
              title: Text(
                item['q']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(item['a']!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
