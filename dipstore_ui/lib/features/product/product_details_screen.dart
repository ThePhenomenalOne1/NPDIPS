import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/widgets/custom_button.dart';
import 'package:dipstore_ui/core/providers/cart_provider.dart';
import 'package:dipstore_ui/features/cart/models/cart_item_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? productData;

  const ProductDetailsScreen({super.key, this.productData});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // Store selected values for each attribute: e.g., {"Size": "M", "Color": "Red"}
  final Map<String, String> _selectedAttributes = {};
  late Map<String, List<String>> _availableAttributes;

  @override
  void initState() {
    super.initState();
    _initAttributes();
  }

  void _initAttributes() {
    final category =
        widget.productData?['category']?.toString().toLowerCase() ?? "other";
    _availableAttributes = _getAttributesForCategory(category);

    // Set defaults (first option)
    _availableAttributes.forEach((key, options) {
      if (options.isNotEmpty) {
        _selectedAttributes[key] = options.first;
      }
    });
  }

  Map<String, List<String>> _getAttributesForCategory(String category) {
    category = category.toLowerCase();

    if (category.contains("cloth") ||
        category.contains("fashion") ||
        category.contains("wear") ||
        category.contains("dress")) {
      return {
        "Size": ["XS", "S", "M", "L", "XL", "XXL"],
        "Color": [
          "Black",
          "White",
          "Navy",
          "Red",
          "Beige",
          "Olive",
          "Burgundy",
          "Teal",
          "Charcoal",
        ],
        "Material": ["Cotton", "Polyester", "Linen", "Silk", "Wool", "Denim"],
        "Style": ["Casual", "Formal", "Streetwear", "Vintage"],
      };
    } else if (category.contains("shoes") || category.contains("footwear")) {
      return {
        "Size (US)": ["7", "8", "9", "10", "11", "12", "13"],
        "Width": ["Standard", "Wide", "Extra Wide"],
        "Color": ["Black", "White", "Grey", "Navy", "Brown", "Tan"],
        "Material": ["Leather", "Suede", "Mesh", "Synthetic"],
      };
    } else if (category.contains("furniture") || category.contains("home")) {
      return {
        "Material": ["Solid Oak", "Walnut Veneer", "Pine", "Marble", "Steel"],
        "Upholstery": ["Velvet", "Leather", "Linen", "Microfiber", "None"],
        "Color": [
          "Charcoal",
          "Emerald",
          "Navy",
          "Oak",
          "Walnut",
          "Cloud White",
        ],
        "Style": ["Mid-Century", "Industrial", "Modern", "Scandinavian"],
      };
    } else if (category.contains("tech") ||
        category.contains("electr") ||
        category.contains("phone") ||
        category.contains("laptop")) {
      return {
        "Color": [
          "Black",
          "White",
          "Silver",
          "Space Grey",
          "Gold",
          "Midnight Green",
          "Sierra Blue",
        ],
        "Storage": ["128GB", "256GB", "512GB", "1TB"],
        "Processor": ["Standard", "Upgraded", "Ultra"],
      };
    } else if (category.contains("beauty") ||
        category.contains("skincare") ||
        category.contains("cosmetic")) {
      return {
        "Skin Type": ["All Types", "Dry", "Oily", "Sensitive", "Combination"],
        "Size": ["30ml", "50ml", "100ml"],
        "Finish": ["Matte", "Dewy", "Natural", "Satin"],
      };
    } else if (category.contains("coffee") ||
        category.contains("drink") ||
        category.contains("bean")) {
      return {
        "Roast Level": ["Light", "Medium", "Dark", "French Roast"],
        "Grind Size": [
          "Whole Bean",
          "Espresso",
          "Drip",
          "French Press",
          "Cold Brew",
        ],
        "Weight": ["250g", "500g", "1kg"],
      };
    } else if (category.contains("perfume") || category.contains("fragrance")) {
      return {
        "Concentration": [
          "Eau de Toilette",
          "Eau de Parfum",
          "Parfum",
          "Cologne",
        ],
        "Size": ["30ml", "50ml", "100ml"],
        "Intensity": ["Subtle", "Moderate", "Strong"],
      };
    }

    // Default / Other
    return {
      "Option": ["Standard", "Premium"],
      "Size": ["S", "M", "L"],
      "Color": ["Black", "White", "Grey"],
    };
  }



  @override
  Widget build(BuildContext context) {
    // Mock Data if productData is null
    final title = widget.productData?['name'] ?? "Product Name";
    final brand = widget.productData?['brand'] ?? "Brand";
    final price = widget.productData?['price'] ?? "\$0.00";
    final imageUrl =
        widget.productData?['imageUrl'] ?? "https://via.placeholder.com/400";

    return Scaffold(
      extendBody: true, // Allow body to extend behind bottom bar
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: BackButton(
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(imageUrl, fit: BoxFit.cover),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {},
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            brand,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.textSubLight,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        price,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      Text(
                        "Description",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing),
                      Text(
                        "High quality product selected just for you. Features premium materials and excellent craftsmanship. Perfect for your daily needs.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSubLight,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      Text(
                        "Shipping Information",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacing),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_shipping_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppTheme.spacing),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Estimated Delivery",
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSubLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  "2-4 Business Days",
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // DYNAMIC ATTRIBUTES SECTION
                      ..._buildOptionsSection(),

                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(AppTheme.spacingL),
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.elevation2,
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Buy Now - Secondary (optional)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () =>
                            _handleAddToCart(context, buyNow: true),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          ),
                        ),
                        child: const Text(
                          "Buy Now",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing),
                    // Add to Bag - Primary
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: "Add to Bag",
                        height: 50,
                        onPressed: () => _handleAddToCart(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOptionsSection() {
    return _availableAttributes.entries.map((entry) {
      final attributeName = entry.key;
      final options = entry.value;

      // If it's color, show the selected color name in the label
      String label = attributeName;
      if (attributeName == "Color" &&
          _selectedAttributes.containsKey("Color")) {
        label = "$attributeName: ${_selectedAttributes['Color']}";
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSubLight,
            ),
          ),
          const SizedBox(height: AppTheme.spacing),
          Wrap(
            spacing: AppTheme.spacing,
            runSpacing: AppTheme.spacing,
            children: options.map((option) {
              final isSelected = _selectedAttributes[attributeName] == option;
              final isColor = attributeName == "Color";

              if (isColor) {
                // Premium Color Circle Selection
                final color = _getColor(option);
                return GestureDetector(
                  onTap: () => setState(
                    () => _selectedAttributes[attributeName] = option,
                  ),
                  child: Tooltip(
                    message: option,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(
                        3,
                      ), // Space between ring and circle
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Standard Text Chip Selection
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedAttributes[attributeName] = option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderLight.withOpacity(0.5),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.spacingL),
        ],
      );
    }).toList();
  }

  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case "black":
        return Colors.black;
      case "white":
      case "cloud white":
        return Colors.white;
      case "red":
        return Colors.red;
      case "blue":
        return Colors.blue;
      case "green":
        return Colors.green;
      case "navy":
        return const Color(0xFF000080);
      case "beige":
        return const Color(0xFFF5F5DC);
      case "yellow":
        return Colors.yellow;
      case "gold":
        return const Color(0xFFFFD700);
      case "silver":
        return const Color(0xFFC0C0C0);
      case "space grey":
        return const Color(0xFF717378);
      case "rose gold":
        return const Color(0xFFB76E79);
      case "midnight green":
        return const Color(0xFF004953);
      case "sierra blue":
        return const Color(0xFF69A1C9);
      case "olive":
        return const Color(0xFF808000);
      case "burgundy":
        return const Color(0xFF800020);
      case "teal":
        return Colors.teal;
      case "charcoal":
        return const Color(0xFF36454F);
      case "neon green":
        return const Color(0xFF39FF14);
      case "neon orange":
        return const Color(0xFFFF5F1F);
      case "royal blue":
        return const Color(0xFF4169E1);
      case "emerald":
        return const Color(0xFF50C878);
      case "tan":
        return const Color(0xFFD2B48C);
      case "brown":
        return Colors.brown;
      case "grey":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _handleAddToCart(BuildContext context, {bool buyNow = false}) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    // Extract and parse data
    final id =
        widget.productData?['id'] ??
        widget.productData?['productId'] ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final name = widget.productData?['name'] ?? "Unknown Product";
    final brand = widget.productData?['brand'] ?? "";
    final storeId = widget.productData?['storeId'] ?? "unknown_store";
    final storeName = widget.productData?['storeName'] ?? "Store";

    // Parse price string
    String priceStr = widget.productData?['price'] ?? "0";
    priceStr = priceStr.replaceAll('\$', '').replaceAll(',', '').trim();
    final price = double.tryParse(priceStr) ?? 0.0;

    final imageUrl = widget.productData?['imageUrl'];

    // Format subtitle string from attributes
    final attributesList = _selectedAttributes.entries
        .map((e) => "${e.key}: ${e.value}")
        .join(" | ");

    final subtitle =
        "$brand${attributesList.isNotEmpty ? '\n$attributesList' : ''}";

    final cartItem = CartItemModel(
      id: id,
      title: name,
      subtitle: subtitle,
      price: price,
      imageUrl: imageUrl,
      storeId: storeId,
      storeName: storeName,
      quantity: 1,
    );

    if (buyNow) {
      // Instant checkout for this item
      context.push('/checkout', extra: cartItem);
    } else {
      // Add to store-specific bag
      cart.addToCart(cartItem);

      // Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Added to $storeName Bag"),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 1),
        ),
      );

      // Return to store page
      context.pop();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
