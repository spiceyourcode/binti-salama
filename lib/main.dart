import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/database_service.dart';
import 'services/authentication_service.dart';
import 'services/panic_button_service.dart';
import 'services/service_locator_service.dart';
import 'services/incident_log_service.dart';
import 'services/settings_service.dart';
import 'services/language_provider.dart';
import 'services/google_places_service.dart';
import 'services/disguise_mode_provider.dart';
import 'services/biometric_service.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

// Global notification plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if running on web - show warning
  if (kIsWeb) {
    runApp(const WebNotSupportedApp());
    return;
  }

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
    // Initialize API key from environment
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    AppConstants.initializeApiKey(apiKey);
  } catch (e) {
    // .env file may not exist, continue without it
    // API key can still be loaded from local.properties on Android
    // ignore: avoid_print
    print('Info: .env file not loaded: $e');
  }

  // Set preferred orientations (portrait only for security)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize local notifications
  // Use the app launcher icon resource name (without the @/mipmap/ prefix).
  // Some projects may not include generated mipmap icons; initialize in a try/catch
  // so the app doesn't crash at startup if the resource is missing.
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  try {
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  } catch (e) {
    // If initialization fails (missing resources on Android), log and continue.
    // This prevents the app from failing to start due to notification icon issues.
    // ignore: avoid_print
    print('Warning: flutterLocalNotifications initialization failed: $e');
  }

  // Initialize database
  final databaseService = DatabaseService();
  await databaseService.initialize();

  runApp(BintiSalamaApp(databaseService: databaseService));
}

class BintiSalamaApp extends StatelessWidget {
  final DatabaseService databaseService;

  const BintiSalamaApp({
    super.key,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: databaseService),
        Provider<GooglePlacesService>(
          create: (_) => GooglePlacesService(apiKey: AppConstants.googleMapsApiKey),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<BiometricService>(
          create: (_) => BiometricService(),
        ),
        ProxyProvider<DatabaseService, AuthenticationService>(
          update: (_, db, __) => AuthenticationService(databaseService: db),
        ),
        ProxyProvider<DatabaseService, PanicButtonService>(
          update: (_, db, __) => PanicButtonService(databaseService: db),
        ),
        ProxyProvider2<DatabaseService, GooglePlacesService, ServiceLocatorService>(
          update: (_, db, places, __) => ServiceLocatorService(
            databaseService: db,
            googlePlacesService: places,
          ),
        ),
        ProxyProvider<DatabaseService, IncidentLogService>(
          update: (_, db, __) => IncidentLogService(databaseService: db),
        ),
        ProxyProvider<DatabaseService, SettingsService>(
          update: (_, db, __) => SettingsService(databaseService: db),
        ),
        // LanguageProvider depends on AuthenticationService and SettingsService.
        ChangeNotifierProxyProvider2<AuthenticationService, SettingsService,
            LanguageProvider>(
          create: (_) => LanguageProvider(),
          update: (_, auth, settings, provider) {
            provider ??= LanguageProvider();
            provider.authenticationService = auth;
            provider.settingsService = settings;
            // Attempt to load initial language async (no await here)
            provider.loadInitialLanguage();
            return provider;
          },
        ),
        // DisguiseModeProvider for app-wide disguise mode state
        ChangeNotifierProxyProvider2<AuthenticationService, SettingsService,
            DisguiseModeProvider>(
          create: (_) => DisguiseModeProvider(),
          update: (_, auth, settings, provider) {
            provider ??= DisguiseModeProvider();
            provider.setDependencies(auth, settings);
            // Load disguise mode setting
            provider.loadDisguiseMode();
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppConstants.primaryColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

/// Web Not Supported Warning Screen
class WebNotSupportedApp extends StatelessWidget {
  const WebNotSupportedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.phone_android,
                        size: 80,
                        color: Color(0xFF6A1B9A),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Binti Salama',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Mobile App Required',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Binti Salama is designed specifically for mobile devices to ensure your safety and privacy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Please download the app on your:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.android,
                                size: 48,
                                color: Colors.green[700],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Android Phone',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(width: 48),
                          Column(
                            children: [
                              Icon(
                                Icons.apple,
                                size: 48,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'iPhone',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'The mobile app includes GPS tracking, offline access, and secure encrypted storage.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
