import 'package:go_router/go_router.dart';
import 'package:dipstore_ui/features/splash/splash_screen.dart';
import 'package:dipstore_ui/features/onboarding/user_type_screen.dart';
import 'package:dipstore_ui/features/auth/auth_screen.dart';
import 'package:dipstore_ui/features/auth/register_screen.dart';
import 'package:dipstore_ui/features/shell/main_shell.dart';
import 'package:dipstore_ui/features/business/business_details_screen.dart';
import 'package:dipstore_ui/features/product/product_details_screen.dart';
import 'package:dipstore_ui/features/business/business_verification_screen.dart';
import 'package:dipstore_ui/features/cart/checkout_screen.dart';
import 'package:dipstore_ui/features/cart/models/cart_item_model.dart';
import 'package:dipstore_ui/features/cart/models/order_model.dart';
import 'package:dipstore_ui/features/cart/order_details_screen.dart';
import 'package:dipstore_ui/features/cart/store_orders_details_screen.dart';
import 'package:dipstore_ui/features/auth/phone_auth_screen.dart';
import 'package:dipstore_ui/features/auth/otp_verification_screen.dart';
import 'package:dipstore_ui/features/cart/store_bag_screen.dart';


class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/user-type',
        builder: (_, __) => const UserTypeScreen(),
      ),
      GoRoute(
        path: '/business-verification',
        builder: (_, __) => const BusinessVerificationScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/phone-auth',
        builder: (_, __) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) {
          if (state.extra is Map<String, dynamic>) {
            final data = state.extra as Map<String, dynamic>;
            return OtpVerificationScreen(
              phoneNumber: data['phone'] ?? data['phoneNumber'] ?? "",
              registrationData: data['registrationData'],
              is2fa: data['is2fa'] == true,
            );
          }
          final phone = state.extra as String? ?? "";
          return OtpVerificationScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        name: 'store-bag',
        path: '/store-bag',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return StoreBagScreen(
            storeId: data['storeId'],
            storeName: data['storeName'],
          );
        },
      ),
      GoRoute(
        path: '/business-details',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return BusinessDetailsScreen(
            storeId: data?['storeId'] ?? '',
            businessName: data?['name'] ?? "Store",
            category: data?['category'] ?? "General",
            tagline: data?['tagline'] ?? "",
            about: data?['about'] ?? "",
            imageUrl: data?['imageUrl'],
            phoneNumber: data?['phoneNumber'],
          );
        },
      ),
      GoRoute(
        path: '/product-details',
        builder: (context, state) {
           final data = state.extra as Map<String, dynamic>?;
           return ProductDetailsScreen(productData: data);
        },
      ),
      GoRoute(
        path: '/shell',
        builder: (_, __) => const MainShell(),
      ),
      GoRoute(
        path: '/order-details',
        builder: (context, state) {
          final order = state.extra as OrderModel;
          return OrderDetailsScreen(order: order);
        },
      ),
      GoRoute(
        path: '/store-orders-details',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final storeName = data['storeName'] as String;
          final orders = (data['orders'] as List).cast<OrderModel>();
          return StoreOrdersDetailsScreen(
            storeName: storeName,
            orders: orders,
          );
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          if (state.extra is CartItemModel) {
             return CheckoutScreen(singleItem: state.extra as CartItemModel);
          } else if (state.extra is Map<String, dynamic>) {
            final data = state.extra as Map<String, dynamic>;
            return CheckoutScreen(
               storeId: data['storeId'],
               storeName: data['storeName'],
            );
          }
          return const CheckoutScreen();
        },
      ),

    ],
  );
}
