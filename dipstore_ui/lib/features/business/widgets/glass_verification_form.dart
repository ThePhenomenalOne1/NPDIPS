import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dipstore_ui/core/widgets/custom_button.dart';
import 'package:dipstore_ui/core/widgets/custom_text_field.dart';

class GlassVerificationForm extends StatelessWidget {
  const GlassVerificationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomTextField(
            label: "Business Name",
            hint: "Enter your business name",
            prefixIcon: Icon(Icons.business_rounded),
          ),
          const SizedBox(height: 20),
          const CustomTextField(
            label: "Business Category",
            hint: "Shop, electronics, clothing...",
            prefixIcon: Icon(Icons.category_outlined),
          ),
          const SizedBox(height: 20),
          const CustomTextField(
            label: "Contact Phone",
            hint: "Enter phone number",
            prefixIcon: Icon(Icons.phone_android_rounded),
          ),
          const SizedBox(height: 20),
          const CustomTextField(
            label: "Business Address",
            hint: "Enter full address",
            prefixIcon: Icon(Icons.location_on_outlined),
            maxLines: 3,
          ),
          const SizedBox(height: 40),

          CustomButton(
            text: "Continue to Login",
            onPressed: () => context.push('/auth'),
          ),
        ],
      ),
    );
  }
}
