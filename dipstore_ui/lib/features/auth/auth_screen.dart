import 'dart:ui';
import 'package:dipstore_ui/core/theme/app_theme.dart';
import 'package:dipstore_ui/core/widgets/custom_button.dart';
import 'package:dipstore_ui/core/widgets/custom_text_field.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final error = await authService.login(
          _emailController.text.trim(), _passwordController.text);

      if (!mounted) return;

      if (error == null) {
        context.go('/shell');
      } else if (error == 'requires_2fa') {
        // Send OTP to the user's registered phone, then go to 2FA verify screen
        final phone = authService.pending2faPhone ?? '';
        authService.sendOtp(
          phone,
          onCodeSent: (_) {
            if (!mounted) return;
            context.push('/otp-verify', extra: {'phone': phone, 'is2fa': true});
          },
          onError: (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Could not send 2FA code: $e'),
                  backgroundColor: AppColors.error),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forgot Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter your email address to reset your password."),
            const SizedBox(height: 16),
            CustomTextField(
              label: "Email",
              controller: emailController,
              hint: "email@gmail.com",
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              Navigator.pop(context);
              if (email.isEmpty) return;
              try {
                await Provider.of<AuthService>(this.context, listen: false)
                    .resetPassword(email);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text("Password reset link sent — check your inbox")),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text("Send Reset Link"),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final error = await Provider.of<AuthService>(context, listen: false)
          .signInWithGoogle();
      if (!mounted) return;
      if (error == null || error == 'Sign in cancelled') {
        if (error == null) context.go('/shell');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showMagicLinkDialog() {
    final emailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) {
        bool isSending = false;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text("Sign in with Magic Link"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "We'll send a one-click sign-in link to your email address.",
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Email",
                  controller: emailController,
                  hint: "email@gmail.com",
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isSending
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty) return;
                        setState(() => isSending = true);
                        final error = await Provider.of<AuthService>(
                          context,
                          listen: false,
                        ).sendMagicLink(email);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(error == null
                                ? 'Magic link sent! Check your inbox.'
                                : 'Error: $error'),
                            backgroundColor:
                                error == null ? null : AppColors.error,
                          ),
                        );
                      },
                child: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Send Link"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.textMainLight),
        backgroundColor: Colors.transparent,
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
            Positioned(
              top: -110,
              right: -70,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC7EBD5).withValues(alpha: 0.7),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFDDF4E8).withValues(alpha: 0.9),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.borderLight.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Please Sign In",
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMainLight,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingS),
                              Text(
                                "Enter your KRD Business Hub account details for a personalized experience.",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSubLight,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingXL),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                                ),
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      label: "Email",
                                      controller: _emailController,
                                      hint: "email@gmail.com",
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      validator: (value) =>
                                          value?.isEmpty ?? true ? "Please enter email" : null,
                                    ),
                                    const SizedBox(height: AppTheme.spacingL),
                                    CustomTextField(
                                      label: "Password",
                                      controller: _passwordController,
                                      obscureText: !_isPasswordVisible,
                                      hint: "********",
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () => setState(
                                          () => _isPasswordVisible = !_isPasswordVisible,
                                        ),
                                      ),
                                      validator: (value) =>
                                          value?.isEmpty ?? true ? "Please enter password" : null,
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  child: Text(
                                    "Forgot Password?",
                                    style: const TextStyle(color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingL),
                              CustomButton(
                                text: "Sign In",
                                onPressed: _login,
                                isLoading: _isLoading,
                                backgroundColor: AppColors.primaryDark,
                                textColor: Colors.white,
                              ),
                              const SizedBox(height: AppTheme.spacingL),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: AppColors.borderLight.withValues(alpha: 0.9)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing),
                                    child: Text(
                                      "Or Sign in with",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSubLight,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: AppColors.borderLight.withValues(alpha: 0.9)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingL),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      text: _isGoogleLoading ? "Signing in..." : "Google",
                                      isOutlined: true,
                                      icon: _isGoogleLoading
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.g_mobiledata_rounded, size: 22),
                                      onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingS),
                              CustomButton(
                                text: "Sign in with Magic Link",
                                isOutlined: true,
                                icon: const Icon(Icons.link_rounded, size: 20),
                                onPressed: _showMagicLinkDialog,
                              ),
                              const SizedBox(height: AppTheme.spacingS),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      text: "Apple",
                                      isOutlined: true,
                                      icon: const Icon(Icons.apple, size: 20),
                                      onPressed: () {},
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingS),
                                  _soonBadge(),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingM),
                              CustomButton(
                                text: "Sign in with Phone Number",
                                isOutlined: true,
                                icon: const Icon(Icons.phone_android_outlined),
                                onPressed: () => context.push('/phone-auth'),
                              ),
                              const SizedBox(height: AppTheme.spacingXL),
                              Center(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
                                          style: const TextStyle(color: AppColors.textSubLight),
                                        ),
                                        GestureDetector(
                                          onTap: () => context.push('/register'),
                                          child: Text(
                                            "Sign Up",
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppTheme.spacing),
                                    TextButton(
                                      onPressed: () => context.go('/shell'),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppTheme.spacingL,
                                          vertical: AppTheme.spacingM,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                        ),
                                      ),
                                      child: Text(
                                        "Continue as Guest",
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textSubLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
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
          ],
        ),
      ),
    );
  }

  Widget _soonBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: const Text(
        "Soon",
        style: TextStyle(
          fontSize: 10,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
