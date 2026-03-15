import 'dart:async';
import 'dart:ui';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';
import 'package:dipstore_ui/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final Map<String, dynamic>? registrationData;
  final bool is2fa;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.registrationData,
    this.is2fa = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsRemaining = 120;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((e) => e.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the full 6-digit code")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.verifyOtp(otp);

      if (!mounted) return;
      if (success) {
        if (widget.is2fa) {
          // Complete the deferred email/password login
          final loginError = await authService.completeLoginAfter2fa();
          if (!mounted) return;
          if (loginError == null) {
            context.go('/shell');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loginError),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else if (widget.registrationData != null) {
          try {
            await authService.register(
              name: widget.registrationData!['name'],
              email: widget.registrationData!['email'],
              password: widget.registrationData!['password'],
              phoneNumber: widget.phoneNumber,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Account created successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
              context.go('/shell');
            }
          } catch (regError) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Registration Error: $regError"),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Verification successful!"),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/shell');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid OTP code. Please try again."),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("System Error: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');

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
            Positioned(top: -90, left: -80, child: _blob(250, const Color(0xFFC8ECD8))),
            Positioned(bottom: -120, right: -80, child: _blob(280, const Color(0xFFDDF4E8))),
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
                                    Icons.security_rounded,
                                    color: AppColors.primary,
                                    size: 40,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),
                              Center(
                                child: Text(
                                  "OTP Verification",
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMainLight,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Text.rich(
                                  TextSpan(
                                    text: "We have sent a 6-digit code to\n",
                                    style: const TextStyle(
                                      color: AppColors.textSubLight,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: widget.phoneNumber,
                                        style: const TextStyle(
                                          color: AppColors.textMainLight,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 34),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (index) {
                                  return SizedBox(
                                    width: 45,
                                    height: 55,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                        child: TextFormField(
                                          controller: _controllers[index],
                                          focusNode: _focusNodes[index],
                                          onChanged: (value) => _onOtpDigitChanged(index, value),
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                            color: AppColors.textMainLight,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white.withValues(alpha: 0.56),
                                            contentPadding: EdgeInsets.zero,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppColors.borderLight.withValues(alpha: 0.9),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: AppColors.primary,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 28),
                              Center(
                                child: Text(
                                  "Expires in $minutes:$seconds",
                                  style: TextStyle(
                                    color: _secondsRemaining < 30
                                        ? Colors.redAccent
                                        : AppColors.textSubLight,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              CustomButton(
                                text: "Verify OTP",
                                onPressed: _verifyOtp,
                                isLoading: _isLoading,
                                backgroundColor: AppColors.primary,
                                textColor: Colors.white,
                                height: 56,
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: TextButton(
                                  onPressed: _secondsRemaining == 0
                                      ? () {
                                          setState(() {
                                            _secondsRemaining = 120;
                                            _startTimer();
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("OTP Resent!")),
                                          );
                                        }
                                      : null,
                                  child: Text(
                                    "Resend Code",
                                    style: TextStyle(
                                      color: _secondsRemaining == 0
                                          ? AppColors.primary
                                          : AppColors.textSubLight,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
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
