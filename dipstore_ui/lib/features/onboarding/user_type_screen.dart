import 'dart:ui';
import 'package:dipstore_ui/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserTypeScreen extends StatelessWidget {
  const UserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/krdchat.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.34),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Sign In",
                            textColor: Colors.white,
                            gradientColors: const [
                              Color(0xCC8AD1F4),
                              Color(0xCCB89EF2),
                            ],
                            onPressed: () => context.push('/auth'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CustomButton(
                            text: "Register",
                            textColor: Colors.white,
                            gradientColors: const [
                              Color(0xCC6ACFC9),
                              Color(0xCC7B94F2),
                            ],
                            onPressed: () => context.push('/register'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
