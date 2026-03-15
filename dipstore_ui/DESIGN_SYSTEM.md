# Kurdistan Business Hub - iOS 26.2.1 Design System

## 🎨 Design Philosophy

Kurdistan Business Hub follows the **iOS 26.2.1 Unified Design Language**, emphasizing:
- **Simplicity**: Clean, uncluttered interfaces with purposeful whitespace
- **Elegance**: Refined typography, smooth animations, and premium aesthetics
- **Clarity**: Clear visual hierarchy and intuitive navigation patterns
- **Consistency**: Unified design tokens across all screens

---

## 🌈 Color Palette

### Primary Colors
```dart
Primary Green: #6DBB82 (rgb(109, 187, 130))
Primary Dark:  #4A8F5D (for contrast and depth)
Primary Light: #8FD6A3 (for accents and highlights)
```

### Secondary/Accent
```dart
Accent Gold:   #F59E0B (Amber 500 - for CTAs and highlights)
Brand Gold:    #BF8A2C (for premium branding elements)
```

### Backgrounds
```dart
Light Mode:    #F3F4F6 (Gray 100 - soft, easy on eyes)
Dark Mode:     #111827 (Gray 900 - deep, rich black)
```

### Surfaces
```dart
Light Surface: #FFFFFF (Pure white cards)
Dark Surface:  #1F2937 (Gray 800 - elevated dark cards)
```

### Typography Colors
```dart
Light Mode Text:
  - Main:      #111827 (Gray 900 - high contrast)
  - Secondary: #6B7280 (Gray 500 - subtle)

Dark Mode Text:
  - Main:      #F9FAFB (Gray 50 - soft white)
  - Secondary: #9CA3AF (Gray 400 - muted)
```

### Semantic Colors
```dart
Success:  #10B981 (Green - confirmations, completed orders)
Error:    #EF4444 (Red - errors, cancelled orders)
Warning:  #F59E0B (Amber - pending, alerts)
Info:     #3B82F6 (Blue - informational messages)
```

---

## 📐 Spacing System (iOS-style)

```dart
// Consistent spacing scale
4px   - Micro spacing (icon padding)
8px   - Tight spacing (between related elements)
12px  - Small spacing (list item padding)
16px  - Base spacing (standard padding)
24px  - Medium spacing (section separation)
32px  - Large spacing (major sections)
48px  - XL spacing (screen top/bottom)
64px  - XXL spacing (hero sections)
```

---

## 🔤 Typography System

### Font Family
```dart
Primary: SF Pro Display (iOS native)
Fallback: Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto
```

### Type Scale
```dart
Display Large:   34px / 41px line-height / Bold (Hero titles)
Display Medium:  28px / 34px line-height / Bold (Page titles)
Headline Large:  24px / 32px line-height / Semibold (Section headers)
Headline Medium: 20px / 28px line-height / Semibold (Card titles)
Body Large:      17px / 22px line-height / Regular (Primary content)
Body Medium:     15px / 20px line-height / Regular (Secondary content)
Body Small:      13px / 18px line-height / Regular (Captions, labels)
Label:           11px / 13px line-height / Medium (Badges, tags)
```

---

## 🎯 Border Radius System

```dart
// iOS-style rounded corners
4px   - Subtle (badges, tags)
8px   - Small (buttons, input fields)
12px  - Medium (cards, containers)
16px  - Large (modals, bottom sheets)
20px  - XL (hero cards, featured content)
24px  - XXL (full-screen modals)
999px - Pill (fully rounded buttons)
```

---

## 🌟 Elevation & Shadows

### Light Mode Shadows
```dart
// Subtle, iOS-style shadows
Elevation 1 (Cards):
  - Shadow: 0px 1px 3px rgba(0, 0, 0, 0.08)
  - Offset: (0, 1)
  - Blur: 3px

Elevation 2 (Floating buttons):
  - Shadow: 0px 4px 12px rgba(0, 0, 0, 0.10)
  - Offset: (0, 4)
  - Blur: 12px

Elevation 3 (Modals, dialogs):
  - Shadow: 0px 8px 24px rgba(0, 0, 0, 0.12)
  - Offset: (0, 8)
  - Blur: 24px
```

### Dark Mode Shadows
```dart
// Lighter shadows for dark backgrounds
Elevation 1: 0px 1px 3px rgba(0, 0, 0, 0.3)
Elevation 2: 0px 4px 12px rgba(0, 0, 0, 0.4)
Elevation 3: 0px 8px 24px rgba(0, 0, 0, 0.5)
```

---

## 🧩 Component Design Specifications

### 1. Navigation Bar (iOS-style)
```dart
Height: 44px (compact) / 96px (large with title)
Background: Translucent blur (frosted glass effect)
Border: 1px bottom border with opacity 0.2
Title: Headline Large, centered or leading-aligned
Back Button: iOS chevron-left icon
Actions: Icon buttons, 44x44 tap target
```

### 2. Buttons

#### Primary Button
```dart
Height: 50px
Padding: 16px horizontal
Background: Primary Green (#6DBB82)
Text: Body Large, White, Semibold
Border Radius: 12px
Shadow: Elevation 1
Hover/Press: Darken 10%, scale 0.98
```

#### Secondary Button (Outlined)
```dart
Height: 50px
Padding: 16px horizontal
Background: Transparent
Border: 1.5px solid Primary Green
Text: Body Large, Primary Green, Semibold
Border Radius: 12px
Hover/Press: Background Primary Green 10% opacity
```

#### Text Button
```dart
Height: 44px
Padding: 12px horizontal
Background: Transparent
Text: Body Medium, Primary Green, Semibold
Hover/Press: Background Primary Green 5% opacity
```

### 3. Input Fields
```dart
Height: 56px
Padding: 16px horizontal
Background: Surface color
Border: 1px solid Border color
Border Radius: 12px
Label: Body Small, Secondary text, above field
Placeholder: Body Medium, Secondary text, opacity 0.5
Focus State: Border Primary Green 2px, shadow glow
Error State: Border Error color, helper text below
```

### 4. Cards

#### Standard Card
```dart
Padding: 16px
Background: Surface color
Border Radius: 12px
Shadow: Elevation 1
Border: Optional 1px border with opacity 0.1
```

#### Product Card
```dart
Aspect Ratio: 3:4 (image)
Padding: 12px
Background: Surface color
Border Radius: 16px
Shadow: Elevation 1
Image: Border radius 12px (top)
Content: 12px padding below image
```

#### Business Card
```dart
Height: Auto (min 120px)
Padding: 16px
Background: Surface color
Border Radius: 16px
Shadow: Elevation 2
Logo: 64x64, border radius 12px
Content: Flex layout with spacing
```

### 5. Bottom Navigation Bar
```dart
Height: 80px (with safe area)
Background: Surface with blur effect
Border: 1px top border with opacity 0.2
Items: 4-5 items, evenly spaced
Icon Size: 24x24
Label: Body Small, below icon
Active State: Primary Green color
Inactive State: Secondary text color
Indicator: Optional pill background for active item
```

### 6. Search Bar
```dart
Height: 44px
Padding: 12px horizontal
Background: Surface color with opacity 0.8
Border Radius: 12px
Icon: 20x20 search icon, leading
Placeholder: Body Medium, Secondary text
Clear Button: Trailing, appears when typing
```

### 7. Badges & Tags
```dart
Height: 24px
Padding: 6px horizontal
Background: Primary color with opacity 0.1
Text: Label size, Primary color, Medium weight
Border Radius: 6px
```

### 8. Modals & Bottom Sheets

#### Modal
```dart
Width: 90% of screen (max 400px)
Padding: 24px
Background: Surface color
Border Radius: 24px
Shadow: Elevation 3
Title: Headline Medium
Content: Body Medium
Actions: Button row at bottom
```

#### Bottom Sheet
```dart
Width: 100%
Padding: 24px
Background: Surface color
Border Radius: 24px (top corners only)
Handle: 36x4 rounded bar, centered, 12px from top
Content: Scrollable if needed
```

---

## 📱 Screen-Specific Design Guidelines

### Authentication Screens (Login, Register, Phone Auth)

**Layout:**
- Max width: 450px, centered
- Padding: 24px all sides
- Vertical spacing: 24px between sections

**Elements:**
- Title: Display Medium, Bold
- Subtitle: Body Medium, Secondary color
- Input fields: 56px height, 12px radius
- Primary CTA: Full width, 50px height
- Divider: "Or continue with" text with lines
- Social buttons: Outlined, with icons
- **Continue as Guest**: Text button, centered, below social options
- Footer links: Body Small, centered

**Visual Enhancements:**
- Subtle gradient background (optional)
- Frosted glass card for form (optional)
- Smooth transitions between login/register

---

### Home/Dashboard Screen

**Layout:**
- Hero banner: Full width, 200px height
- Category grid: 2 columns, 16px gap
- Product sections: Horizontal scrollable lists
- Spacing: 16px between sections

**Elements:**
- App bar: Translucent, with logo and profile
- Search bar: Prominent, 44px height
- Category cards: Square, 12px radius, icon + label
- Product cards: 3:4 ratio, 16px radius
- Section headers: Headline Large, with "See All" link

**Visual Enhancements:**
- Parallax scroll effect on hero
- Smooth card animations on scroll
- Skeleton loaders for content

---

### Product Details Screen

**Layout:**
- Image carousel: Full width, 1:1 ratio
- Content: Scrollable, 24px padding
- Sticky footer: Add to bag button

**Elements:**
- Image gallery: Swipeable, dot indicators
- Product title: Headline Large, Bold
- Price: Headline Medium, Primary color
- Rating: Stars + count
- Description: Body Medium, expandable
- Size/Color selector: Chip group
- Quantity selector: +/- buttons with count
- Add to bag: Primary button, full width

**Visual Enhancements:**
- Image zoom on tap
- Smooth transitions between images
- Haptic feedback on selection

---

### Shopping Bag/Cart Screen

**Layout:**
- Header: "Shopping Bag" title
- Item list: Scrollable
- Summary card: Sticky at bottom
- Checkout button: Below summary

**Elements:**
- Cart item: Image + details + quantity + remove
- Empty state: Icon + message + CTA
- Summary: Subtotal, tax, shipping, total
- Promo code: Input field with apply button
- Checkout: Primary button, full width

**Visual Enhancements:**
- Swipe to delete animation
- Quantity update animations
- Price calculation transitions

---

### Profile Screen

**Layout:**
- Header: User info card
- Menu sections: Grouped lists
- Logout: Destructive button at bottom

**Elements:**
- Avatar: 80x80, circular
- User name: Headline Medium
- Email: Body Small, Secondary
- Menu items: 56px height, icon + label + chevron
- Section headers: Label size, uppercase
- Logout: Text button, Error color

**Visual Enhancements:**
- Glassmorphism on header card
- Smooth navigation transitions
- Confirmation dialog for logout

---

### Business Details Screen

**Layout:**
- Cover image: Full width, 200px height
- Business info: Card below cover
- Products grid: 2 columns
- Contact buttons: Floating or sticky

**Elements:**
- Cover: Gradient overlay for text
- Logo: 80x80, overlapping cover
- Business name: Headline Large
- Category + location: Body Small, Secondary
- Rating: Stars + reviews count
- Contact: WhatsApp + Phone buttons
- Products: Grid of product cards

**Visual Enhancements:**
- Parallax cover image
- Smooth scroll animations
- Contact button haptics

---

### Order History Screen

**Layout:**
- Tabs: Pending, Completed, Cancelled
- Order list: Scrollable cards
- Empty state: Per tab

**Elements:**
- Order card: Business + product + status
- Order number: Body Small, Secondary
- Date/time: Body Small, Secondary
- Price: Headline Small, Bold
- Status badge: Color-coded (Green/Orange/Red)
- Tap to details: Chevron indicator

**Visual Enhancements:**
- Tab indicator animation
- Status color transitions
- Skeleton loading for orders

---

### Search Screen

**Layout:**
- Search bar: Sticky at top
- Filters: Horizontal chips below search
- Results: Grid or list view toggle
- Empty state: No results message

**Elements:**
- Search input: 44px, with clear button
- Filter chips: Pill-shaped, toggleable
- Result cards: Product or business cards
- View toggle: Grid/list icons

**Visual Enhancements:**
- Search suggestions dropdown
- Filter animations
- Smooth layout transitions

---

## 🎬 Animation & Transitions

### Micro-interactions
```dart
Button press: Scale 0.98, duration 100ms
Card tap: Scale 0.98, duration 150ms
Toggle switch: Slide + color, duration 200ms
Checkbox: Scale + checkmark draw, duration 250ms
```

### Page Transitions
```dart
Push: Slide from right, duration 300ms, curve: easeOut
Pop: Slide to right, duration 250ms, curve: easeIn
Modal: Fade + scale from 0.9, duration 300ms
Bottom sheet: Slide from bottom, duration 350ms
```

### Loading States
```dart
Skeleton: Shimmer effect, 1.5s cycle
Spinner: Circular, Primary color, 1s rotation
Pull to refresh: iOS-style spinner
```

---

## ♿ Accessibility

- **Minimum tap target**: 44x44 pixels
- **Color contrast**: WCAG AA (4.5:1 for text)
- **Focus indicators**: 2px outline, Primary color
- **Screen reader**: Semantic labels for all interactive elements
- **Dynamic type**: Support iOS text size preferences
- **Haptic feedback**: On important interactions

---

## 📐 Responsive Breakpoints

```dart
Mobile:  < 600px (primary target)
Tablet:  600px - 1024px (adaptive layout)
Desktop: > 1024px (centered, max width 1200px)
```

---

## 🎨 Design Principles Summary

1. **Whitespace is Premium**: Don't overcrowd screens
2. **Consistency is Key**: Use design tokens religiously
3. **Feedback is Essential**: Every action needs visual response
4. **Performance Matters**: Smooth 60fps animations
5. **Accessibility First**: Design for everyone
6. **iOS Native Feel**: Follow Apple's HIG guidelines
7. **Brand Identity**: Subtle gold accents for premium feel
8. **User-Centric**: Clear hierarchy, intuitive navigation

---

## 🚀 Implementation Checklist

- [ ] Update all screens to use unified spacing system
- [ ] Apply consistent border radius (12px for cards, 8px for buttons)
- [ ] Implement iOS-style navigation bars
- [ ] Add micro-animations to all interactive elements
- [ ] Ensure all buttons meet 50px minimum height
- [ ] Apply elevation shadows to cards and modals
- [ ] Implement translucent blur effects where appropriate
- [ ] Add haptic feedback to key interactions
- [ ] Test color contrast for accessibility
- [ ] Verify all tap targets are minimum 44x44
- [ ] Add loading states and skeleton screens
- [ ] Implement smooth page transitions
- [ ] Add "Continue as Guest" option to auth screen
- [ ] Test on multiple iOS devices and screen sizes

---

**Design Version**: 1.0  
**Last Updated**: February 2026  
**iOS Version**: 26.2.1  
**App**: Kurdistan Business Hub
