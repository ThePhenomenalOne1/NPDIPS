import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _togglingTwoFactor = false;

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    final lastSignIn = firebaseUser?.metadata.lastSignInTime;
    final creationTime = firebaseUser?.metadata.creationTime;
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    final bool twoFaEnabled = user?.isTwoFactorEnabled ?? false;
    final bool hasPhone =
        user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login & Security"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader("Account Security"),
          _buildInfoTile(context, "Email", user?.email ?? "N/A", Icons.email),
          _buildInfoTile(
            context,
            "Last Sign In",
            lastSignIn != null ? dateFormat.format(lastSignIn) : "Unknown",
            Icons.history,
          ),
          _buildInfoTile(
            context,
            "Account Created",
            creationTime != null ? dateFormat.format(creationTime) : "Unknown",
            Icons.calendar_today,
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Two-Factor Authentication (2FA)"),
          _buildTwoFactorTile(
              context, twoFaEnabled, hasPhone, authService, user?.phoneNumber),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: () => _showResetDialog(context, user?.email),
            icon: const Icon(Icons.lock_reset),
            label: const Text("Change Password"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoFactorTile(
    BuildContext context,
    bool enabled,
    bool hasPhone,
    AuthService authService,
    String? phone,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (enabled ? Colors.green : Colors.grey)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: enabled ? Colors.green : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Two-Factor Authentication",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enabled
                          ? "Enabled â€” OTP sent to ${_maskedPhone(phone)}"
                          : "Disabled â€” add a phone number to enable",
                      style: TextStyle(
                        fontSize: 12,
                        color: enabled ? Colors.green[700] : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (_togglingTwoFactor)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch(
                  value: enabled,
                  activeColor: Colors.green,
                  onChanged: hasPhone
                      ? (v) => _toggleTwoFactor(context, v, authService)
                      : null,
                ),
            ],
          ),
          if (!hasPhone)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Add a phone number in Personal Information to enable 2FA.",
                        style:
                            TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _maskedPhone(String? phone) {
    if (phone == null || phone.length < 4) return '***';
    return '${phone.substring(0, phone.length - 4).replaceAll(RegExp(r'\d'), '*')}${phone.substring(phone.length - 4)}';
  }

  Future<void> _toggleTwoFactor(
      BuildContext context, bool enable, AuthService authService) async {
    setState(() => _togglingTwoFactor = true);
    try {
      final phone = authService.currentUser?.phoneNumber;
      if (enable) {
        if (phone == null || phone.isEmpty) {
          throw 'Add a phone number in Personal Information first.';
        }

        // Start enrollment via Firebase phone verification and prompt for code
        await authService.startEnrollPhone(phone, onCodeSent: (vid) async {
          // Prompt user for code
          final code = await showDialog<String>(
            context: context,
            builder: (ctx) {
              final controller = TextEditingController();
              return AlertDialog(
                title: const Text('Enter verification code'),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'SMS code'),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Verify')),
                ],
              );
            },
          );
          if (code != null && code.isNotEmpty) {
            final res = await authService.confirmEnrollPhone(vid, code);
            if (res != null) throw res;
          } else {
            throw 'Enrollment cancelled';
          }
        }, onError: (err) {
          throw err;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('2FA enabled'), backgroundColor: Colors.green),
          );
        }
      } else {
        await authService.setTwoFactorEnabled(false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('2FA disabled')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _togglingTwoFactor = false);
    }
  }

  void _showResetDialog(BuildContext context, String? email) {
    if (email == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Text("Send a password reset email to $email?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<AuthService>(
                  context,
                  listen: false,
                ).resetPassword(email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Reset email sent! Check your inbox."),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text("Send Email"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
