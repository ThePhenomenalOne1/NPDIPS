import 'dart:ui';
import 'package:dipstore_ui/core/utils/kurdistan_phone_formatter.dart';
import 'package:dipstore_ui/core/widgets/custom_button.dart';
import 'package:dipstore_ui/core/widgets/custom_text_field.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(text: '+964 ');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Relaxed regex: allows +964 followed by any 10 digits (ignoring spaces)
  final _phoneRegex = RegExp(
    r'^\+964\s*[0-9\s]{10,}$',
  );

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigits = false;
  bool _hasSpecialChars = false;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isTooltipVisible = false;
  static const TextStyle _strongRegisterHint = TextStyle(
    color: Color(0xFF3E4C45),
    fontWeight: FontWeight.w700,
  );

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordValidation);
  }

  void _updatePasswordValidation() {
    final text = _passwordController.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasUppercase = text.contains(RegExp(r'[A-Z]'));
      _hasLowercase = text.contains(RegExp(r'[a-z]'));
      _hasDigits = text.contains(RegExp(r'\d'));
      _hasSpecialChars = text.contains(RegExp(r'[@$!%*?&]'));
    });
    if (_isTooltipVisible && _overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _showPasswordTooltip() {
    if (_isTooltipVisible) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isTooltipVisible = true;
  }

  void _hidePasswordTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isTooltipVisible = false;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, -230),
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Password Requirements",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildReqItem("At least 8 characters", _hasMinLength),
                      _buildReqItem("At least 1 uppercase letter", _hasUppercase),
                      _buildReqItem("At least 1 lowercase letter", _hasLowercase),
                      _buildReqItem("At least 1 number", _hasDigits),
                      _buildReqItem("At least 1 special char (@\$!%*?&)", _hasSpecialChars),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReqItem(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            color: met ? Colors.greenAccent : Colors.grey,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: met ? Colors.white : Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.removeListener(_updatePasswordValidation);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    if (_isTooltipVisible) _hidePasswordTooltip();
    super.dispose();
  }

  Future<void> _handleRegisterWithOtp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final cleanPhone = _phoneController.text.replaceAll(' ', '');
      await authService.sendOtp(
        cleanPhone,
        onCodeSent: (verificationId) {
          if (mounted) {
            setState(() => _isLoading = false);
            context.push(
              '/otp-verify',
              extra: {
                'phoneNumber': cleanPhone,
                'registrationData': {
                  'name': _nameController.text.trim(),
                  'email': _emailController.text.trim(),
                  'password': _passwordController.text,
                  'phoneNumber': cleanPhone,
                },
              },
            );
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
        title: const Text("Let's Get Started"),
        leading: const BackButton(color: AppColors.textMainLight),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textMainLight,
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
              top: -120,
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
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
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
                              color: AppColors.borderLight.withValues(alpha: 0.85),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Create an account to continue.",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSubLight,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        label: "Username",
                                        hint: "Enter your username",
                                        controller: _nameController,
                                        prefixIcon: const Icon(Icons.person_outline),
                                        hintTextStyle: _strongRegisterHint,
                                        labelColor: const Color(0xFF1F2E27),
                                        validator: (value) => value?.isEmpty ?? true
                                            ? "Please enter username"
                                            : null,
                                      ),
                                      const SizedBox(height: 24),
                                      CustomTextField(
                                        label: "Email",
                                        hint: "name@example.com",
                                        controller: _emailController,
                                        prefixIcon: const Icon(Icons.email_outlined),
                                        hintTextStyle: _strongRegisterHint,
                                        labelColor: const Color(0xFF1F2E27),
                                        validator: (value) => value?.isEmpty ?? true
                                            ? "Please enter email"
                                            : null,
                                      ),
                                      const SizedBox(height: 24),
                                      CustomTextField(
                                        label: "Phone Number",
                                        controller: _phoneController,
                                        hint: "50 123 4567",
                                        keyboardType: TextInputType.phone,
                                        hintTextStyle: _strongRegisterHint,
                                        labelColor: const Color(0xFF1F2E27),
                                        inputFormatters: [KurdistanPhoneFormatter()],
                                        validator: (value) {
                                          if (value == null || value.trim() == '+964 ') {
                                            return "Please enter phone number";
                                          }
                                          if (!_phoneRegex.hasMatch(value.trim())) {
                                            return "Invalid Format. Example: +964 750 123 4567";
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                CompositedTransformTarget(
                                  link: _layerLink,
                                  child: MouseRegion(
                                    onEnter: (_) => _showPasswordTooltip(),
                                    onExit: (_) => _hidePasswordTooltip(),
                                    child: CustomTextField(
                                      label: "Password",
                                      hint: "Enter a strong password",
                                      controller: _passwordController,
                                      obscureText: !_isPasswordVisible,
                                      hintTextStyle: _strongRegisterHint,
                                      labelColor: const Color(0xFF1F2E27),
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter password";
                                        }
                                        final regex = RegExp(
                                          r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$",
                                        );
                                        if (!regex.hasMatch(value)) {
                                          return "Does not meet password requirements";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                CustomTextField(
                                  label: "Confirm Password",
                                  hint: "Re-enter your password",
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  hintTextStyle: _strongRegisterHint,
                                  labelColor: const Color(0xFF1F2E27),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () => setState(
                                      () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                                    ),
                                  ),
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? "Please confirm password" : null,
                                ),
                                const SizedBox(height: 32),
                                CustomButton(
                                  text: "Continue to Verify",
                                  onPressed: _handleRegisterWithOtp,
                                  isLoading: _isLoading,
                                  backgroundColor: AppColors.primary,
                                  textColor: Colors.white,
                                ),
                                const SizedBox(height: 24),
                                const Row(
                                  children: [
                                    Expanded(child: Divider()),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: Text("Or continue with"),
                                    ),
                                    Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                CustomButton(
                                  text: "Continue with Google",
                                  isOutlined: true,
                                  icon: const Icon(Icons.g_mobiledata),
                                  onPressed: () {},
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  text: "Continue with Apple",
                                  isOutlined: true,
                                  icon: const Icon(Icons.apple),
                                  onPressed: () {},
                                ),
                                const SizedBox(height: 32),
                                Center(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Already have an account? ",
                                            style: TextStyle(
                                              color: AppColors.textSubLight,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => context.pop(),
                                            child: const Text(
                                              "Sign In",
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: () => context.go('/shell'),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
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
            ),
          ],
        ),
      ),
    );
  }
}
