import 'package:flutter/material.dart';
import 'widgets/glass_profile_card.dart';
import 'widgets/glass_section.dart';
import 'widgets/profile_section_header.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import 'user_management_screen.dart';
import 'widgets/profile_menu_tile.dart';
import 'personal_info_screen.dart';
import 'security_screen.dart';
import 'faq_screen.dart';
import 'package:go_router/go_router.dart';

import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/features/orders/order_history_screen.dart';
import 'store_management_screen.dart';
import 'permission_manager_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const GlassProfileCard(), // We'll refactor the widget content itself to be clean
            const SizedBox(height: 32),

            const ProfileSectionHeader(title: "Account Settings"),
            GlassSection(
              children: [
                ProfileMenuTile(
                  icon: Icons.person_outline_rounded,
                  title: "Personal Information",
                  color: AppColors.primary,
                   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoScreen())),
                ),
                ProfileMenuTile(
                  icon: Icons.security_rounded,
                  title: "Login & Security",
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen())),
                ),
                const ProfileMenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: "Notifications",
                  color: AppColors.primary,
                  trailing: Text(
                    "ON",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            
            // Superadmin Only Section
            Consumer<AuthService>(
              builder: (context, auth, _) {
                if (auth.currentUser?.role == 'Superadmin') {
                  return Column(
                    children: [
                      const ProfileSectionHeader(title: "Admin Controls"),
                      GlassSection(
                        children: [
                          ProfileMenuTile(
                            icon: Icons.store_rounded,
                            title: "Manage Stores",
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const StoreManagementScreen()),
                              );
                            },
                          ),
                          ProfileMenuTile(
                            icon: Icons.supervisor_account_rounded,
                            title: "Accounts",
                            color: Colors.purple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                              );
                            },
                          ),
                          ProfileMenuTile(
                            icon: Icons.admin_panel_settings_rounded,
                            title: "Permission Manager",
                            color: Colors.deepOrange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PermissionManagerScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const ProfileSectionHeader(title: "Orders & Payments"),
            GlassSection(
              children: [
                ProfileMenuTile(
                  icon: Icons.shopping_bag_outlined,
                  title: "My Orders",
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
                ),
                ProfileMenuTile(
                  icon: Icons.credit_card_rounded,
                  title: "Payment Methods",
                  color: AppColors.primary,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Methods coming soon!"))),
                ),
              ],
            ),

            const SizedBox(height: 24),
            GlassSection(
              children: [
                ProfileMenuTile(
                  icon: Icons.help_outline_rounded,
                  title: "Help & Support",
                  color: AppColors.primary,
                   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQScreen())),
                ),
                ProfileMenuTile(
                  icon: Icons.logout_rounded,
                  title: "Log Out",
                  color: Colors.redAccent.shade200,
                  hideArrow: true,
                  onTap: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Log Out"),
                        content: const Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Log Out", style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );

                    if (shouldLogout == true && context.mounted) {
                      await Provider.of<AuthService>(context, listen: false).logout();
                      if (context.mounted) {
                        context.go('/auth');
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
