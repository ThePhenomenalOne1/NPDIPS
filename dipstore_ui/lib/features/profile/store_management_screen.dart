import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dipstore_ui/core/services/store_service.dart';
import 'package:dipstore_ui/core/services/product_service.dart';
import 'package:dipstore_ui/core/services/auth_service.dart';
import 'package:dipstore_ui/features/home/models/store_model.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/widgets/custom_button.dart';
import 'package:dipstore_ui/core/widgets/custom_text_field.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dipstore_ui/core/services/storage_service.dart';
import 'store_items_screen.dart';

class StoreManagementScreen extends StatelessWidget {
  const StoreManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Stores"), centerTitle: false),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStoreDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Store"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<StoreModel>>(
        stream: context.read<StoreService>().getStores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final stores = snapshot.data ?? [];
          if (stores.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No stores yet", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return _StoreCard(store: store);
            },
          );
        },
      ),
    );
  }

  void _showAddStoreDialog(BuildContext context) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final taglineController = TextEditingController();
    final aboutController = TextEditingController();
    XFile? selectedImage;
    bool isFeatured = false;

    Future<void> addStore(
      BuildContext context,
      TextEditingController name,
      TextEditingController category,
      TextEditingController tagline,
      TextEditingController about,
      XFile? selectedImage,
      bool isFeatured,
    ) async {
      if (name.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter store name")),
        );
        return;
      }

      try {
        final user = context.read<AuthService>().currentUser;
        String? imageUrl;
        if (selectedImage != null) {
          imageUrl = await context.read<StorageService>().uploadImage(
            file: selectedImage,
            path: 'stores',
          );
        }

        // ignore: use_build_context_synchronously
        await context.read<StoreService>().addStore(
          name: name.text.trim(),
          ownerId: user?.id ?? '',
          category: category.text.trim(),
          tagline: tagline.text.trim(),
          about: about.text.trim(),
          isFeatured: isFeatured,
          imageUrl: imageUrl,
        );
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Store added successfully")),
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

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add New Store"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() => selectedImage = image);
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      image: selectedImage != null
                          ? DecorationImage(
                              image: kIsWeb
                                  ? NetworkImage(selectedImage!.path)
                                  : FileImage(File(selectedImage!.path))
                                        as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: selectedImage == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Add Store Image",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: nameController,
                  label: "Store Name",
                  hint: "Enter store name",
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: categoryController,
                  label: "Category",
                  hint: "e.g., Fashion, Electronics",
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: taglineController,
                  label: "Tagline",
                  hint: "Short description",
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: aboutController,
                  label: "About",
                  hint: "Detailed description",
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: isFeatured,
                  onChanged: (value) =>
                      setState(() => isFeatured = value ?? false),
                  title: const Text("Featured Store"),
                  contentPadding: EdgeInsets.zero,
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
              onPressed: () => addStore(
                context,
                nameController,
                categoryController,
                taglineController,
                aboutController,
                selectedImage,
                isFeatured,
              ),
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreModel store;

  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (store.isFeatured) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Featured",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.category,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.tagline,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Delete", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditStoreDialog(context, store);
                    } else if (value == 'delete') {
                      _confirmDelete(context, store);
                    }
                  },
                ),
              ],
            ),
            if (store.imageUrl != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  store.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            CustomButton(
              text: "Manage Items",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoreItemsScreen(store: store),
                  ),
                );
              },
              icon: const Icon(Icons.inventory_2_outlined, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStoreDialog(BuildContext context, StoreModel store) {
    final nameController = TextEditingController(text: store.name);
    final categoryController = TextEditingController(text: store.category);
    final taglineController = TextEditingController(text: store.tagline);
    final aboutController = TextEditingController(text: store.about);
    XFile? selectedImage;
    bool isFeatured = store.isFeatured;

    Future<void> updateStore(
      BuildContext context,
      StoreModel store,
      TextEditingController name,
      TextEditingController category,
      TextEditingController tagline,
      TextEditingController about,
      XFile? selectedImage,
      bool isFeatured,
    ) async {
      try {
        String? imageUrl = store.imageUrl;
        if (selectedImage != null) {
          imageUrl = await context.read<StorageService>().uploadImage(
            file: selectedImage,
            path: 'stores',
          );
        }

        final updatedStore = StoreModel(
          id: store.id,
          name: name.text.trim(),
          ownerId: store.ownerId,
          category: category.text.trim(),
          tagline: tagline.text.trim(),
          about: about.text.trim(),
          isFeatured: isFeatured,
          imageUrl: imageUrl,
          createdAt: store.createdAt,
        );

        // ignore: use_build_context_synchronously
        await context.read<StoreService>().updateStore(store.id, updatedStore);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Store updated successfully")),
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

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Store"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() => selectedImage = image);
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      image: selectedImage != null
                          ? DecorationImage(
                              image: kIsWeb
                                  ? NetworkImage(selectedImage!.path)
                                  : FileImage(File(selectedImage!.path))
                                        as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : store.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(store.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: selectedImage == null && store.imageUrl == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Change Store Image",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
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
                CustomTextField(
                  controller: aboutController,
                  label: "About",
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: isFeatured,
                  onChanged: (value) =>
                      setState(() => isFeatured = value ?? false),
                  title: const Text("Featured Store"),
                  contentPadding: EdgeInsets.zero,
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
              onPressed: () => updateStore(
                context,
                store,
                nameController,
                categoryController,
                taglineController,
                aboutController,
                selectedImage,
                isFeatured,
              ),
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, StoreModel store) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Store"),
        content: Text(
          "Are you sure you want to delete '${store.name}'? This will also delete all associated items.",
        ),
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
        // Delete associated products first
        await context.read<ProductService>().deleteProductsByStore(store.id);
        // Then delete the store
        // ignore: use_build_context_synchronously
        await context.read<StoreService>().deleteStore(store.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Store deleted successfully")),
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
