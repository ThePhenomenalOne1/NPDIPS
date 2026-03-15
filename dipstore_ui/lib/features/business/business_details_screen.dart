import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:dipstore_ui/core/services/product_service.dart';
import 'package:dipstore_ui/core/services/auth_service.dart';
import 'package:dipstore_ui/core/services/store_service.dart';
import 'package:dipstore_ui/core/services/review_service.dart';
import 'package:dipstore_ui/features/product/models/product_model.dart';
import 'package:dipstore_ui/features/product/models/review_model.dart';
import 'package:dipstore_ui/core/utils/icon_utils.dart';
import 'package:dipstore_ui/core/widgets/product_card.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/widgets/star_rating.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:dipstore_ui/core/providers/cart_provider.dart';
import 'widgets/business_info_chip.dart';
import 'widgets/store_action_button.dart';

class BusinessDetailsScreen extends StatefulWidget {
  final String businessName;
  final String category;
  final String tagline;
  final String about;
  final String storeId;
  final String? imageUrl;
  final String? phoneNumber;

  const BusinessDetailsScreen({
    super.key,
    required this.businessName,
    required this.category,
    required this.tagline,
    required this.about,
    required this.storeId,
    this.imageUrl,
    this.phoneNumber,
  });

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  double _userRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Business Header (Top Section)
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.surfaceLight,
            leading: const BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.bgLight,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          boxShadow: AppTheme.elevation2,
                        ),
                        child:
                            widget.imageUrl != null &&
                                widget.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  widget.imageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    getBusinessIcon(widget.category),
                                    size: 50,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                getBusinessIcon(widget.category),
                                size: 50,
                                color: AppColors.primary,
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.businessName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSubLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Consumer<AuthService>(
                builder: (context, auth, _) {
                  if (auth.currentUser == null) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.stars_rounded, color: Colors.amber),
                    tooltip: "Rating Insights",
                    onPressed: () => _showReviewsSheet(context),
                  );
                },
              ),
              // ADDED: Bag Icon with badge for this specific store
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  // Get items ONLY for this store
                  final storeItems = cart.getItemsForStore(widget.storeId);
                  final itemCount = storeItems.fold(
                    0,
                    (sum, item) => sum + item.quantity,
                  );

                  return IconButton(
                    onPressed: () {
                      context.pushNamed(
                        'store-bag',
                        extra: {
                          'storeId': widget.storeId,
                          'storeName': widget.businessName,
                        },
                      );
                    },
                    icon: Badge(
                      isLabelVisible: itemCount > 0,
                      label: Text('$itemCount'),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // 📍 2. Business Information
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: AppTheme.elevation1,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const BusinessInfoChip(
                      icon: Icons.location_on_outlined,
                      label: "Erbil, KRD",
                    ),
                    GestureDetector(
                      onTap: () => _showContactDialog(context),
                      child: const BusinessInfoChip(
                        icon: Icons.phone_android_rounded,
                        label: "Contact",
                      ),
                    ),
                    const BusinessInfoChip(
                      icon: Icons.schedule_rounded,
                      label: "9 AM - 6 PM",
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ℹ️ About Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.about,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSubLight,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🎯 Action Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final authService = context.watch<AuthService>();
                        final user = authService.currentUser;

                        if (user == null) {
                          return StoreActionButton(
                            label: "Follow Store",
                            icon: Icons.add_circle_outline_rounded,
                            isPrimary: true,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please login to follow stores",
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        return StreamBuilder<bool>(
                          stream: context.read<StoreService>().isStoreFollowed(
                            user.id,
                            widget.storeId,
                          ),
                          builder: (context, snapshot) {
                            final isFollowing = snapshot.data ?? false;

                            return StoreActionButton(
                              label: isFollowing ? "Following" : "Follow Store",
                              icon: isFollowing
                                  ? Icons.check_circle_rounded
                                  : Icons.add_circle_outline_rounded,
                              isPrimary: !isFollowing,
                              onPressed: () async {
                                final storeService = context
                                    .read<StoreService>();
                                try {
                                  if (isFollowing) {
                                    await storeService.unfollowStore(
                                      user.id,
                                      widget.storeId,
                                    );
                                  } else {
                                    await storeService.followStore(
                                      user.id,
                                      widget.storeId,
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error: $e")),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StoreActionButton(
                      label: "Contact Seller",
                      icon: Icons.chat_bubble_outline_rounded,
                      onPressed: () => _showContactDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ⭐ Rate this Store Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Builder(
                builder: (context) {
                  final auth = context.watch<AuthService>();
                  final user = auth.currentUser;

                  if (user == null || user.role == 'Guest') {
                    return const SizedBox.shrink(); // Hide if not logged in or Guest
                  }

                  return StreamBuilder<List<ReviewModel>>(
                    stream: context.read<ReviewService>().getReviews(
                      widget.storeId,
                    ),
                    builder: (context, snapshot) {
                      final reviews = snapshot.data ?? [];
                      final hasRated = reviews.any((r) => r.userId == user.id);

                      if (hasRated) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              // ignore: deprecated_member_use
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "You have already rated this store.",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          boxShadow: AppTheme.elevation1,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Rate this Store",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your feedback helps others discover local gems",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSubLight),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StarRating(
                                  rating: _userRating,
                                  size: 32,
                                  onRatingChanged: (rating) =>
                                      setState(() => _userRating = rating),
                                ),
                                if (_userRating > 0)
                                  _isSubmitting
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: _submitReview,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: const Text("Submit"),
                                        ),
                              ],
                            ),
                            if (_userRating > 0) ...[
                              const SizedBox(height: 16),
                              TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: "Write a comment (optional)",
                                  hintStyle: const TextStyle(fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // 🛍️ 3. Products Grid Header
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Product Catalog",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "View All",
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

          // 🛍️ 3. Products Grid - DYNAMIC
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: StreamBuilder<List<ProductModel>>(
              stream: context.read<ProductService>().getProductsByStore(
                widget.storeId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No products available yet",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = products[index];
                    return ProductCard(
                      imageUrl: product.imageUrl,
                      name: product.name,
                      price: "\$${product.price.toStringAsFixed(2)}",
                      onTap: () {
                        context.push(
                          '/product-details',
                          extra: {
                            'name': product.name,
                            'brand': product.brand,
                            'price': "\$${product.price.toStringAsFixed(2)}",
                            'category': product.category ?? widget.category,
                            'imageUrl': product.imageUrl,
                            'storeId': widget.storeId,
                            'storeName': widget.businessName,
                            'productId': product.id,
                          },
                        );
                      },
                    );
                  }, childCount: products.length),
                );
              },
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final storeId = widget.storeId;
          final storeItems = cart.getItemsForStore(storeId);
          final itemCount = storeItems.fold(
            0,
            (sum, item) => sum + item.quantity,
          );

          if (itemCount == 0) return const SizedBox.shrink();

          final total = cart.getSubtotal(storeId);

          return Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              boxShadow: AppTheme.elevation2,
            ),
            child: SafeArea(
              child: InkWell(
                onTap: () {
                  context.pushNamed(
                    'store-bag',
                    extra: {
                      'storeId': storeId,
                      'storeName': widget.businessName,
                    },
                  );
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "$itemCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "View Your Bag",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Text(
                      "\$${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showReviewsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: Colors.amber,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Store Rating Insights",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<ReviewModel>>(
                stream: context.read<ReviewService>().getReviews(
                  widget.storeId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final reviews = snapshot.data ?? [];
                  if (reviews.isEmpty) {
                    return const Center(
                      child: Text("No ratings yet for this store."),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // ignore: deprecated_member_use
                                CircleAvatar(
                                  backgroundColor: AppColors.primary
                                      // ignore: deprecated_member_use
                                      .withOpacity(0.1),
                                  child: Text(
                                    review.userName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Who Rated: ${review.userName}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        DateFormat.yMMMd().format(
                                          review.createdAt,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textSubLight,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text(
                                  "Stars: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                StarRating(rating: review.rating, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  "${review.rating.toStringAsFixed(1)} / 5.0",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (review.comment != null &&
                                review.comment!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              // ignore: deprecated_member_use
                              Container(
                                padding: const EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: AppColors.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Recommendation:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      review.comment!,
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    // If no phone number is available, show an error
    if (widget.phoneNumber == null || widget.phoneNumber!.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              SizedBox(width: 12),
              Text("Contact Information"),
            ],
          ),
          content: const Text(
            "Contact information is not available for this business.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.chat, color: AppColors.primary),
            SizedBox(width: 12),
            Text("Contact Seller"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose how you'd like to contact this business:"),
            const SizedBox(height: 20),
            // WhatsApp Button
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: const Color(0xFF25D366).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.chat_bubble, color: Color(0xFF25D366)),
              ),
              title: const Text(
                "WhatsApp",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(widget.phoneNumber!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openWhatsApp(context),
            ),
            const Divider(),
            // Phone Call Button
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.phone, color: AppColors.primary),
              ),
              title: const Text(
                "Phone Call",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(widget.phoneNumber!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _makePhoneCall(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    // Remove any non-digit characters from phone number
    String phoneNumber = widget.phoneNumber!.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure the phone number starts with country code
    // If it starts with 0, replace with country code (assuming Iraq +964)
    if (phoneNumber.startsWith('0')) {
      phoneNumber = '+964${phoneNumber.substring(1)}';
    } else if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+964$phoneNumber';
    }

    // Create WhatsApp URL with a pre-filled message
    final whatsappUrl = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent("Hi, I'm interested in your products on KRD Business Hub!")}',
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("WhatsApp is not installed on this device"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error opening WhatsApp: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    String phoneNumber = widget.phoneNumber!.replaceAll(RegExp(r'[^\d+]'), '');

    final phoneUrl = Uri.parse('tel:$phoneNumber');

    try {
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Unable to make phone calls on this device"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error making phone call: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitReview() async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to rate stores")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final review = ReviewModel(
      id: "",
      userId: user.id,
      userName: user.name,
      targetId: widget.storeId,
      rating: _userRating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await context.read<ReviewService>().addReview(review);
      if (mounted) {
        setState(() {
          _userRating = 0;
          _commentController.clear();
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thank you for your rating!")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
