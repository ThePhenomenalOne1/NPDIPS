import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dipstore_ui/core/services/auth_service.dart';
import 'package:dipstore_ui/core/models/user_model.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';

class PermissionManagerScreen extends StatelessWidget {
  const PermissionManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;

    // Guard: only Superadmin can access
    if (currentUser?.role != 'Superadmin') {
      return Scaffold(
        appBar: AppBar(title: const Text("Permission Manager")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Access Denied",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Permission Manager"),
        centerTitle: false,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: context.read<AuthService>().getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final admins = (snapshot.data ?? [])
              .where((u) => u.role == 'Admin' && u.status == 'Active')
              .toList();

          if (admins.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No Admin accounts found",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Create Admin users via Accounts to manage permissions here.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: admins.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _AdminPermissionCard(admin: admins[index]);
            },
          );
        },
      ),
    );
  }
}

// ── Card shown in the list ─────────────────────────────────────────────────────

class _AdminPermissionCard extends StatelessWidget {
  final UserModel admin;
  const _AdminPermissionCard({required this.admin});

  @override
  Widget build(BuildContext context) {
    final grantedCount = admin.permissions.length;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            admin.name.isNotEmpty ? admin.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          admin.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(admin.email,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              grantedCount == 0
                  ? 'No permissions granted'
                  : '$grantedCount permission${grantedCount == 1 ? '' : 's'} granted',
              style: TextStyle(
                fontSize: 11,
                color: grantedCount == 0
                    ? Colors.grey
                    : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: TextButton.icon(
          onPressed: () => _showPermissionEditor(context, admin),
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: const Text("Edit"),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        onTap: () => _showPermissionEditor(context, admin),
      ),
    );
  }

  void _showPermissionEditor(BuildContext context, UserModel admin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PermissionEditorSheet(admin: admin),
    );
  }
}

// ── Bottom-sheet permission editor ────────────────────────────────────────────

class _PermissionEditorSheet extends StatefulWidget {
  final UserModel admin;
  const _PermissionEditorSheet({required this.admin});

  @override
  State<_PermissionEditorSheet> createState() => _PermissionEditorSheetState();
}

class _PermissionEditorSheetState extends State<_PermissionEditorSheet> {
  late List<String> _selected;
  bool _isSaving = false;

  // ── Permission catalogue ───────────────────────────────────────────────────
  static const List<MapEntry<String, String>> _standardPermissions = [
    MapEntry('manage_users', 'Manage Users'),
    MapEntry('manage_stores', 'Manage Stores'),
    MapEntry('view_analytics', 'View Analytics'),
    MapEntry('system_settings', 'System Settings'),
  ];

  static const List<MapEntry<String, String>> _superadminPermissions = [
    MapEntry('approve_stores', 'Approve Store Applications'),
    MapEntry('manage_featured', 'Manage Featured Stores'),
    MapEntry('manage_commissions', 'Manage Commission Rates'),
    MapEntry('view_finances', 'View Full Financials'),
    MapEntry('approve_withdrawals', 'Approve Withdrawal Requests'),
    MapEntry('create_admins', 'Create Admin Accounts'),
  ];

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.admin.permissions);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Drag handle ──────────────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.admin.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.admin.email,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            // ── Scrollable permission list ────────────────────────────────────
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _sectionHeader(
                    icon: Icons.settings_outlined,
                    label: 'Standard Permissions',
                    color: AppColors.primary,
                  ),
                  ..._standardPermissions.map(_permTile),

                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),

                  _sectionHeader(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Superadmin-Level Privileges',
                    color: Colors.orange,
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'These privileges grant elevated access normally reserved for Superadmin.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.orange[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._superadminPermissions.map(_permTile),

                  const SizedBox(height: 24),
                ],
              ),
            ),
            // ── Save button ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Permissions',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
      {required IconData icon,
      required String label,
      required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color),
          ),
        ],
      ),
    );
  }

  Widget _permTile(MapEntry<String, String> perm) {
    final isChecked = _selected.contains(perm.key);
    return CheckboxListTile(
      value: isChecked,
      onChanged: (v) => setState(() {
        if (v == true) {
          _selected.add(perm.key);
        } else {
          _selected.remove(perm.key);
        }
      }),
      title: Text(perm.value,
          style: const TextStyle(fontSize: 14)),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
      dense: true,
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await context
          .read<AuthService>()
          .updateUserDetails(uid: widget.admin.id, permissions: _selected);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Permissions updated successfully')),
        );
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
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
