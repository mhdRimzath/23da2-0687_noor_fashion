import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/profile_image_provider.dart';
import 'providers/address_provider.dart';
import 'providers/settings_provider.dart';
import 'services/firestore_service.dart';
import 'services/firestore_profile_service.dart';
import 'services/firebase_storage_service.dart';
import 'services/connectivity_service.dart';
import 'repositories/migration_repository.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    await FirestoreService().migrateCurrentUserProfile(currentUser);
  }
  debugPrint('Migration checks complete');

  // Initialize Migration Services
  final firestoreProfileService = FirestoreProfileService();
  final firebaseStorageService = FirebaseStorageService();
  final connectivityService = ConnectivityService();
  
  final migrationRepository = MigrationRepository(
    firestoreService: firestoreProfileService,
    storageService: firebaseStorageService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            repository: migrationRepository,
            connectivityService: connectivityService,
          )..loadAndMigrateProfile(currentUser?.uid ?? ''),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileImageProvider()..loadCurrentImage(),
        ),
      ],
      child: const NoorApp(),
    ),
  );
}

class NoorApp extends StatelessWidget {
  const NoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<SettingsProvider>().darkMode;

    return MaterialApp(
      title: 'Noor Fashion',
      debugShowCheckedModeBanner: false,
      theme: NoorTheme.lightTheme,
      darkTheme: NoorTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                return MainNavigation(
                  isLoggedIn: snapshot.hasData,
                );
              },
            ),
      },
    );
  }
}
