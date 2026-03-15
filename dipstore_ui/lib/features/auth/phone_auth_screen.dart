import 'dart:ui';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';
import 'package:dipstore_ui/core/utils/kurdistan_phone_formatter.dart';
import 'package:dipstore_ui/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController(text: '+964 ');
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Relaxed regex: allows +964 followed by any 10 digits (ignoring spaces)
  // Matches +964 750 123 4567 format conceptually
  final _phoneRegex = RegExp(
    r'^\+964\s*[0-9\s]{10,}$',
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final cleanPhone = _phoneController.text.replaceAll(' ', '');
      await authService.sendOtp(
        cleanPhone,
        onCodeSent: (otpCode) {
          if (mounted) {
            setState(() => _isLoading = false);

            final isDevOtp = RegExp(r'^\d{6}$').hasMatch(otpCode);
            if (isDevOtp) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Colors.white,
                  title: const Text(
                    "📱 OTP Code",
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: Text(
                          otpCode,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "⏰ Valid for 10 minutes",
                        style: TextStyle(color: AppColors.textSubLight, fontSize: 12),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Continue", style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ).then((_) {
                if (mounted) {
                  context.push('/otp-verify', extra: cleanPhone);
                }
              });
            } else {
              context.push('/otp-verify', extra: cleanPhone);
            }
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error: $error"),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("System Error: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textMainLight),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF4FAF6),
              Color(0xFFEEF7F1),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -100, right: -100, child: _blob(300, const Color(0xFFC8ECD8))),
            Positioned(bottom: -50, left: -50, child: _blob(200, const Color(0xFFDDF4E8))),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.8)),
                            boxShadow: AppTheme.elevation1,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.phone_android_rounded,
                                      color: AppColors.primary,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: Text(
                                    "Kurdistan Business Hub",
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMainLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    "Enter your phone number to receive a verification code.",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSubLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  "Phone Number",
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textMainLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                                    child: TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      style: const TextStyle(
                                        color: AppColors.textMainLight,
                                        fontSize: 17,
                                        letterSpacing: 1.0,
                                      ),
                                      inputFormatters: [KurdistanPhoneFormatter()],
                                      decoration: InputDecoration(
                                        hintText: "50 123 4567",
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF5A6861),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                        fillColor: Colors.white.withValues(alpha: 0.56),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.9)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.9)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: const BorderSide(
                                            color: AppColors.primary,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim() == '+964 ') {
                                          return "Please enter your phone number";
                                        }
                                        // Simple check: starts with +964 and has enough digits
                                        if (!_phoneRegex.hasMatch(value.trim())) {
                                          return "Invalid Format. Example: +964 750 123 4567";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                CustomButton(
                                  text: "Send OTP",
                                  onPressed: _sendOtp,
                                  isLoading: _isLoading,
                                  backgroundColor: AppColors.primary,
                                  textColor: Colors.white,
                                  height: 56,
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: GestureDetector(
                                    onTap: () => context.pop(),
                                    child: const Text.rich(
                                      TextSpan(
                                        text: "Already have an account? ",
                                        style: TextStyle(
                                          color: AppColors.textSubLight,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "Sign In",
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.55),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
