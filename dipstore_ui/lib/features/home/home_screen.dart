import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';
import 'package:dipstore_ui/core/widgets/custom_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/services/auth_service.dart';
import 'package:dipstore_ui/core/models/user_model.dart';
import 'package:dipstore_ui/core/services/store_service.dart';
import 'package:dipstore_ui/features/home/models/store_model.dart';
import 'package:dipstore_ui/features/home/widgets/business_card.dart';
import 'package:dipstore_ui/features/home/widgets/hero_banner.dart';
import 'package:dipstore_ui/features/business/widgets/store_action_button.dart';
import 'package:dipstore_ui/core/widgets/krd_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  static const int _pageSize = 8;

  // Streams are stored in state so they are created once and not
  // re-instantiated every time AuthService notifyListeners() causes a rebuild.
  Stream<List<StoreModel>>? _storesStream;
  Stream<List<StoreModel>>? _featuredStoresStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _storesStream ??= context.read<StoreService>().getStores();
    _featuredStoresStream ??= context.read<StoreService>().getFeaturedStores();
  }

  @override
  Widget build(BuildContext context) {
    // Watch current user for role-based access
    final user = context.watch<AuthService>().currentUser;
    final isSuperadmin = user?.role == 'Superadmin';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
              color: Theme.of(context).appBarTheme.backgroundColor?.withValues(alpha: 0.7),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "KRD",
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: AppColors.textMainLight,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 8),
            const KrdLogo(size: 32),
            const SizedBox(width: 8),
            Text(
              "HUB",
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: AppColors.textMainLight,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textMainLight,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Banner Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: const HeroBanner(),
            ),
          ),

          // Admin Controls (Add Store)
          if (isSuperadmin)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingL,
                  vertical: AppTheme.spacing,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacing),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        border: Border.all(
                          color: AppColors.borderLight.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Admin Controls",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing),
                          StoreActionButton(
                            label: "Add New Store",
                            icon: Icons.add_business,
                            isPrimary: true,
                            onPressed: () => _showAddStoreDialog(context, user),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Featured Stores Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing,
                      vertical: AppTheme.spacingS,
                    ),
                    color: Colors.white.withValues(alpha: 0.45),
                    child: Text(
                      "Top Hub Businesses",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppTheme.spacingL, AppTheme.spacingM, 0, AppTheme.spacingL),
            sliver: StreamBuilder<List<StoreModel>>(
              stream: _featuredStoresStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint('Featured stores stream error: ${snapshot.error}');
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                final stores = snapshot.data ?? [];
                if (stores.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spacingL),
                      child: Text(
                        "No featured businesses yet.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSubLight,
                        ),
                      ),
                    ),
                  );
                }

                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 190, // Adjusted height for new card design
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: stores.length,
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        return BusinessCard(
                          id: store.id,
                          name: store.name,
                          category: store.category,
                          tagline: store.tagline,
                          about: store.about,
                          imageUrl: store.imageUrl,
                          phoneNumber: store.phoneNumber,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Discovery Hub Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing,
                      vertical: AppTheme.spacingS,
                    ),
                    color: Colors.white.withValues(alpha: 0.45),
                    child: Text(
                      "Discovery Hub",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: AppTheme.spacingM)),

          // All Stores Grid with Pagination
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            sliver: StreamBuilder<List<StoreModel>>(
              stream: _storesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint('Stores stream error: ${snapshot.error}');
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                final stores = snapshot.data ?? [];
                if (stores.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                final totalPages = (stores.length / _pageSize).ceil();
                final clampedPage = _currentPage.clamp(0, totalPages - 1);
                if (clampedPage != _currentPage) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _currentPage = clampedPage);
                  });
                }

                final start = clampedPage * _pageSize;
                final pagedStores = stores.skip(start).take(_pageSize).toList();

                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: AppTheme.spacing,
                          mainAxisSpacing: AppTheme.spacingL,
                        ),
                        itemCount: pagedStores.length,
                        itemBuilder: (context, index) {
                          final store = pagedStores[index];
                          return BusinessCard(
                            id: store.id,
                            name: store.name,
                            category: store.category,
                            tagline: store.tagline,
                            about: store.about,
                            imageUrl: store.imageUrl,
                            phoneNumber: store.phoneNumber,
                          );
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildPaginationControls(totalPages),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            iconSize: 28,
            color: _currentPage > 0 ? AppColors.primary : AppColors.textSubLight,
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
          ),
          const SizedBox(width: 4),
          ...List.generate(totalPages, (index) {
            final isActive = index == _currentPage;
            return GestureDetector(
              onTap: () => setState(() => _currentPage = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            iconSize: 28,
            color: _currentPage < totalPages - 1 ? AppColors.primary : AppColors.textSubLight,
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
          ),
        ],
      ),
    );
  }

  void _showAddStoreDialog(BuildContext context, UserModel? user) {
    // Basic implementation of store adding dialog
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final taglineController = TextEditingController();
    final aboutController = TextEditingController();
    final phoneController = TextEditingController();
    bool isFeatured = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Add New Store", style: Theme.of(context).textTheme.headlineSmall),
          backgroundColor: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusL)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: "Store Name",
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: categoryController,
                  label: "Category",
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: taglineController,
                  label: "Tagline",
                ),
                const SizedBox(height: 16),
                CustomTextField(controller: aboutController, label: "About"),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: phoneController,
                  label: "Phone Number",
                  hint: "+964 XXX XXX XXXX",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: isFeatured,
                  onChanged: (v) => setState(() => isFeatured = v!),
                  title: Text("Featured?", style: Theme.of(context).textTheme.bodyMedium),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: AppColors.textSubLight)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<StoreService>().addStore(
                  name: nameController.text,
                  ownerId: user?.id ?? '',
                  category: categoryController.text,
                  tagline: taglineController.text,
                  about: aboutController.text,
                  phoneNumber: phoneController.text.isNotEmpty
                      ? phoneController.text
                      : null,
                  isFeatured: isFeatured,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}
