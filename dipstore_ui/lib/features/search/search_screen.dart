import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/widgets/animated_search_bar.dart';
import 'package:dipstore_ui/features/home/widgets/business_card.dart';
import 'package:dipstore_ui/core/services/store_service.dart';
import 'package:dipstore_ui/features/home/models/store_model.dart';
import 'widgets/search_tag.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  late TextEditingController _searchController;

  @override
  void initState() {
     super.initState();
     _searchController = TextEditingController();
  }

  @override
  void dispose() {
     _searchController.dispose();
     super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Explore",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMainLight, // Explicit visible color
                          ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSearchBar(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    if (_searchQuery.isEmpty) ...[
                      Text(
                        "Recent Searches",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMainLight, // Explicit visible color
                            ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<StoreService>(
                        builder: (context, storeService, child) {
                          final searches = storeService.recentSearches;
                          if (searches.isEmpty) {
                            return const Text(
                              "No recent searches",
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            );
                          }
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: searches
                                .map((label) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _searchQuery = label;
                                          _searchController.text = label;
                                        });
                                      },
                                      child: SearchTag(label: label),
                                    ))
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "Trending Now",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMainLight, // Explicit visible color
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: StreamBuilder<List<StoreModel>>(
                 stream: context.read<StoreService>().getStores(),
                 builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                       return const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                       );
                    }
                    
                    final allStores = snapshot.data ?? [];
                    // Filter locally to avoid re-fetching from Firestore on every keystroke
                    final filteredStores = _searchQuery.isEmpty 
                        ? allStores 
                        : allStores.where((s) => 
                            s.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            s.category.toLowerCase().contains(_searchQuery.toLowerCase())
                          ).toList();

                    if (filteredStores.isEmpty) {
                       return const SliverToBoxAdapter(
                          child: Center( // Centered text for better visibility
                            child: Padding(
                              padding: EdgeInsets.only(top: 32.0),
                              child: Text(
                                "No businesses found matching your criteria.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                       );
                    }

                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                           final store = filteredStores[index];
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
                        childCount: filteredStores.length,
                      ),
                    );
                 },
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }
}
