# Kurdistan Business Hub - iOS 26.2.1 Implementation Guide

## 📋 Overview

This guide provides step-by-step instructions for implementing the iOS 26.2.1 Unified Design System across the entire Kurdistan Business Hub application. The implementation is **design-only** with **zero risk** to functionality.

---

## ✅ Completed Changes

### 1. Authentication Screens ✓
- **Added "Continue as Guest" button** to both login and register screens
- Positioned below the sign-up/sign-in links
- Styled with iOS-like subtle appearance (gray text, medium weight)
- Navigates to `/shell` route for guest access

**Files Modified:**
- `lib/features/auth/auth_screen.dart`
- `lib/features/auth/register_screen.dart`

---

## 🎯 Implementation Roadmap

### Phase 1: Core Design Tokens (Foundation)
**Priority: CRITICAL** | **Risk: Zero** | **Effort: 2 hours**

#### 1.1 Update Theme Configuration
**File:** `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';

class AppTheme {
  // iOS 26.2.1 Spacing System
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacing = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double spacingXXXL = 64.0;

  // iOS Border Radius System
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusPill = 999.0;

  // iOS Elevation System
  static List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  static List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      offset: const Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.surfaceLight,
      background: AppColors.bgLight,
    ),
    
    // iOS-style Typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        height: 1.2,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        height: 1.33,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        height: 1.29,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        height: 1.33,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        height: 1.38,
        fontWeight: FontWeight.w400,
      ),
      labelMedium: TextStyle(
        fontSize: 11,
        height: 1.18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    ),

    // iOS-style AppBar
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.surfaceLight.withOpacity(0.95),
      foregroundColor: AppColors.textMainLight,
      titleTextStyle: const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: AppColors.textMainLight,
        letterSpacing: -0.5,
      ),
    ),

    // iOS-style Cards
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      color: AppColors.surfaceLight,
      shadowColor: Colors.black.withOpacity(0.08),
    ),

    // iOS-style Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // iOS-style Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),

    // iOS-style Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: AppColors.surfaceLight.withOpacity(0.95),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSubLight,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}
```

---

### Phase 2: Update Core Widgets (Components)
**Priority: HIGH** | **Risk: Zero** | **Effort: 3 hours**

#### 2.1 Custom Button Widget
**File:** `lib/core/widgets/custom_button.dart`

**Changes:**
- Update height to 50px minimum
- Apply 12px border radius
- Add proper elevation shadows
- Implement press animation (scale 0.98)
- Use iOS-style font weights

#### 2.2 Custom Text Field Widget
**File:** `lib/core/widgets/custom_text_field.dart`

**Changes:**
- Update height to 56px
- Apply 12px border radius
- Add focus state with 2px border and subtle glow
- Ensure proper icon sizing (20x20)
- Add iOS-style label positioning

#### 2.3 Product Card Widget
**File:** Create `lib/core/widgets/product_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;
  final double? rating;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: AppTheme.elevation1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image (3:4 ratio)
            AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusL),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.bgLight,
                    child: const Icon(Icons.image, size: 48),
                  ),
                ),
              ),
            ),
            
            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Phase 3: Update Screen Layouts
**Priority: HIGH** | **Risk: Zero** | **Effort: 5 hours**

#### 3.1 Home/Dashboard Screen
**File:** `lib/features/home/home_screen.dart`

**iOS Design Updates:**
- Add translucent frosted glass app bar
- Update search bar to 44px height with 12px radius
- Apply 16px spacing between sections
- Update category cards to square with 12px radius
- Implement horizontal scrollable product lists
- Add section headers with "See All" links
- Apply proper elevation to cards

#### 3.2 Product Details Screen
**File:** `lib/features/product/product_details_screen.dart`

**iOS Design Updates:**
- Full-width image carousel with dot indicators
- 24px padding for content area
- Product title: Headline Large (24px, Bold)
- Price: Headline Medium (20px, Primary color)
- Size/color selectors: Chip style with 8px radius
- Quantity selector: +/- buttons with center count
- Sticky footer: Full-width "Add to Bag" button (50px height)

#### 3.3 Shopping Cart Screen
**File:** `lib/features/cart/cart_screen.dart`

**iOS Design Updates:**
- Cart item cards: 12px radius, elevation 1
- Product image: 80x80 with 12px radius
- Quantity controls: iOS-style +/- buttons
- Summary card: White background, 12px radius
- Checkout button: Full-width, 50px height, primary color

#### 3.4 Business Details Screen
**File:** `lib/features/business/business_details_screen.dart`

**iOS Design Updates:**
- Cover image: Full-width, 200px height with gradient overlay
- Business logo: 80x80, circular, overlapping cover
- Business info card: 16px radius, elevation 2
- Contact buttons: Outlined style, 44px height
- Products grid: 2 columns, 16px gap

#### 3.5 Profile Screen
**File:** `lib/features/profile/profile_screen.dart`

**iOS Design Updates:**
- User info card: Glassmorphism effect
- Avatar: 80x80, circular
- Menu items: 56px height, icon + label + chevron
- Section headers: Label size, uppercase, gray
- Logout button: Text style, error color

#### 3.6 Order History Screen
**File:** `lib/features/orders/order_history_screen.dart`

**iOS Design Updates:**
- Tab bar: iOS-style with sliding indicator
- Order cards: 12px radius, elevation 1
- Status badges: Color-coded pills (6px radius)
  - Green (#10B981) for Completed
  - Orange (#F59E0B) for Pending
  - Red (#EF4444) for Cancelled
- Empty state: Icon + message + CTA

---

### Phase 4: Navigation & Transitions
**Priority: MEDIUM** | **Risk: Zero** | **Effort: 2 hours**

#### 4.1 Update App Router
**File:** `lib/core/router/app_router.dart`

**Changes:**
- Add iOS-style page transitions (slide from right)
- Duration: 300ms for push, 250ms for pop
- Curve: easeOut for push, easeIn for pop

#### 4.2 Bottom Navigation Bar
**File:** `lib/features/shell/shell_screen.dart`

**iOS Design Updates:**
- Height: 80px (including safe area)
- Background: Translucent with blur effect
- Border: 1px top border with opacity 0.2
- Icon size: 24x24
- Active state: Primary color with optional pill background
- Inactive state: Secondary text color

---

### Phase 5: Micro-interactions & Animations
**Priority: LOW** | **Risk: Zero** | **Effort: 3 hours**

#### 5.1 Button Press Animations
- Scale to 0.98 on press
- Duration: 100ms
- Curve: easeOut

#### 5.2 Card Tap Animations
- Scale to 0.98 on tap
- Duration: 150ms
- Add haptic feedback (if supported)

#### 5.3 Loading States
- Implement skeleton screens for content loading
- Shimmer effect: 1.5s cycle
- iOS-style circular progress indicator

#### 5.4 Page Transitions
- Slide from right for push navigation
- Fade + scale for modals
- Slide from bottom for bottom sheets

---

## 📊 Implementation Checklist

### Design Tokens
- [ ] Create `app_theme.dart` with spacing, radius, and elevation systems
- [ ] Update `app_colors.dart` (already complete)
- [ ] Define typography scale matching iOS 26.2.1

### Core Widgets
- [ ] Update `custom_button.dart` with iOS styling
- [ ] Update `custom_text_field.dart` with iOS styling
- [ ] Create `product_card.dart` widget
- [ ] Create `business_card.dart` widget
- [ ] Create `order_card.dart` widget

### Screen Updates
- [ ] Home/Dashboard screen
- [ ] Product details screen
- [ ] Shopping cart screen
- [ ] Business details screen
- [ ] Profile screen
- [ ] Order history screen
- [ ] Search screen
- [ ] Auth screens (✓ Already updated with guest button)

### Navigation & Transitions
- [ ] Update router with iOS-style transitions
- [ ] Update bottom navigation bar styling
- [ ] Add page transition animations

### Micro-interactions
- [ ] Button press animations
- [ ] Card tap animations
- [ ] Loading states and skeletons
- [ ] Haptic feedback (optional)

### Testing & Polish
- [ ] Test on multiple screen sizes
- [ ] Verify color contrast for accessibility
- [ ] Ensure all tap targets are 44x44 minimum
- [ ] Test dark mode (if implemented)
- [ ] Verify smooth 60fps animations

---

## 🎨 Design Principles to Follow

1. **Consistency**: Use design tokens from `app_theme.dart` everywhere
2. **Spacing**: Follow the 4px base spacing scale
3. **Border Radius**: 12px for cards, 8px for buttons, 16px for modals
4. **Elevation**: Use predefined shadow styles (elevation1, elevation2, elevation3)
5. **Typography**: Use theme text styles, don't hardcode font sizes
6. **Colors**: Use `AppColors` constants, never hardcode colors
7. **Tap Targets**: Minimum 44x44 pixels for all interactive elements
8. **Animations**: Keep them subtle and fast (100-300ms)

---

## 🚀 Quick Start

### Step 1: Create Theme File
```bash
# Create the theme file
New-Item -Path "lib/core/theme/app_theme.dart" -ItemType File
```

### Step 2: Update Main App
**File:** `lib/main.dart`

```dart
import 'package:dipstore_ui/core/theme/app_theme.dart';

// In MaterialApp
theme: AppTheme.lightTheme,
```

### Step 3: Start Updating Widgets
Begin with core widgets (buttons, text fields) then move to screens.

---

## 📝 Notes

- **Zero Risk**: All changes are visual only, no logic modifications
- **Incremental**: Can be implemented screen-by-screen
- **Reversible**: Easy to revert if needed
- **Testable**: Test each screen after updating
- **Partner's Color**: Green (#6DBB82) is preserved throughout

---

## 🎯 Success Criteria

✅ All screens follow iOS 26.2.1 design language  
✅ Consistent spacing and border radius throughout  
✅ Smooth animations and transitions  
✅ Accessible (WCAG AA compliant)  
✅ "Continue as Guest" option available  
✅ Partner's green color prominently featured  
✅ Premium, modern aesthetic  

---

**Implementation Guide Version**: 1.0  
**Last Updated**: February 2026  
**Status**: Ready for Implementation
