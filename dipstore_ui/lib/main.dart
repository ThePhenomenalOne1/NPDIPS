import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/auth_service.dart';
import 'core/providers/navigation_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/services/store_service.dart';
import 'core/services/product_service.dart';
import 'core/services/review_service.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const useAuthEmulator = bool.fromEnvironment(
    'USE_AUTH_EMULATOR',
    defaultValue: false,
  );
  const useFirestoreEmulator = bool.fromEnvironment(
    'USE_FIRESTORE_EMULATOR',
    defaultValue: false,
  );
  // Use local Firebase emulators during development to avoid touching production.
  // This will route Auth and Firestore requests to localhost when running in debug.
  if (kDebugMode) {
    if (useAuthEmulator) {
      try {
        FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      } catch (e) {
        // ignore: avoid_print
        print('Could not connect Auth to emulator: $e');
      }
    }
    if (useFirestoreEmulator) {
      try {
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      } catch (e) {
        // ignore: avoid_print
        print('Could not connect Firestore to emulator: $e');
      }
    }
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => StoreService()),
        ChangeNotifierProvider(create: (_) => ReviewService()),
        Provider(create: (_) => ProductService()),
        Provider(create: (_) => StorageService()),
      ],
      child: const KrdApp(),
    ),
  );
}

class KrdApp extends StatelessWidget {
  const KrdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'KRD BUSINESS HUB',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
