import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'widgets/glass_verification_form.dart'; // Keeping import for now, widget content is updated

class BusinessVerificationScreen extends StatelessWidget {
  const BusinessVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
           color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Business\nVerification",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Please provide your business details\nto join our exclusive hub.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSubLight,
                ),
              ),
              const SizedBox(height: 40),
              const GlassVerificationForm(), // Now it is clean despite the name
            ],
          ),
        ),
      ),
    );
  }
}
