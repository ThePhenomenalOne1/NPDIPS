import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final currentIndex = navProvider.currentIndex;

    return Scaffold(
      extendBody: true,
      body: _screens[currentIndex],
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor?.withOpacity(0.70),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                height: 60, // Content height + padding handled by SafeArea
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) => navProvider.setIndex(index),
                  items: _buildNavItems(),
                  // Theme properties are already set in AppTheme, but we ensure background is transparent here
                  // to let the Container's color/blur show through
                  backgroundColor: Colors.transparent, 
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedFontSize: 11,
                  unselectedFontSize: 11,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: "Home",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.search),
        activeIcon: Icon(Icons.search_rounded),
        label: "Search",
      ),
      BottomNavigationBarItem(
        // Converted to normal constructor to allow logic
        icon: Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Badge(
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_bag_outlined),
            );
          },
        ),
        activeIcon: Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Badge(
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_bag_rounded),
            );
          },
        ),
        label: "Bag",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person_rounded),
        label: "Profile",
      ),
    ];
  }
}
