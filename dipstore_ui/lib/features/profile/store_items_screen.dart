import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dipstore_ui/core/services/product_service.dart';
import 'package:dipstore_ui/features/product/models/product_model.dart';
import 'package:dipstore_ui/features/home/models/store_model.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/widgets/custom_text_field.dart';

class StoreItemsScreen extends StatelessWidget {
  final StoreModel store;

  const StoreItemsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${store.name} - Items"), centerTitle: false),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: context.read<ProductService>().getProductsByStore(store.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No items yet", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text(
                    "Tap + to add your first item",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductCard(product: product, storeId: store.id);
            },
          );
        },
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Add New Item"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameController,
                label: "Item Name",
                hint: "Enter item name",
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: brandController,
                label: "Brand",
                hint: "Enter brand name",
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: priceController,
                label: "Price",
                hint: "0.00",
                prefixIcon: const Icon(Icons.attach_money),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: imageUrlController,
                label: "Image URL",
                hint: "https://...",
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: descriptionController,
                label: "Description (Optional)",
                hint: "Item details",
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  priceController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill required fields")),
                );
                return;
              }

              try {
                final newProduct = ProductModel(
                  id: '', // Will be generated by Firestore
                  name: nameController.text.trim(),
                  brand: brandController.text.trim(),
                  price: double.parse(priceController.text.trim()),
                  imageUrl: imageUrlController.text.trim().isEmpty
                      ? 'https://via.placeholder.com/300'
                      : imageUrlController.text.trim(),
                  description: descriptionController.text.trim(),
                  storeId: store.id,
                  createdAt: DateTime.now(),
                );

                await context.read<ProductService>().addProduct(newProduct);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Item added successfully")),
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
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final String storeId;

  const _ProductCard({required this.product, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Image.network(
              product.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 48),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        "\$${product.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () =>
                              _showEditItemDialog(context, product),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red,
                          ),
                          onPressed: () => _confirmDelete(context, product),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, ProductModel product) {
    final nameController = TextEditingController(text: product.name);
    final brandController = TextEditingController(text: product.brand);
    final priceController = TextEditingController(
      text: product.price.toString(),
    );
    final descriptionController = TextEditingController(
      text: product.description ?? '',
    );
    final imageUrlController = TextEditingController(text: product.imageUrl);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Edit Item"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: nameController, label: "Item Name"),
              const SizedBox(height: 16),
              CustomTextField(controller: brandController, label: "Brand"),
              const SizedBox(height: 16),
              CustomTextField(
                controller: priceController,
                label: "Price",
                prefixIcon: const Icon(Icons.attach_money),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: imageUrlController,
                label: "Image URL",
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: descriptionController,
                label: "Description",
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updatedProduct = ProductModel(
                  id: product.id,
                  name: nameController.text.trim(),
                  brand: brandController.text.trim(),
                  price: double.parse(priceController.text.trim()),
                  imageUrl: imageUrlController.text.trim(),
                  description: descriptionController.text.trim(),
                  storeId: storeId,
                  isPopular: product.isPopular,
                  isSellingFast: product.isSellingFast,
                  createdAt: product.createdAt,
                );

                await context.read<ProductService>().updateProduct(
                  product.id,
                  updatedProduct,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Item updated successfully")),
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
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item"),
        content: Text("Are you sure you want to delete '${product.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<ProductService>().deleteProduct(product.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Item deleted successfully")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }
}
