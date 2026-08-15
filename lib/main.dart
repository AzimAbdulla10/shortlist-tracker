import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/constants/constants.dart';
import 'core/database/db_helper.dart';
import 'core/services/auth_service.dart';
import 'core/services/gmail_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/placement_provider.dart';
import 'core/theme/theme.dart';
import 'presentation/screens/main_navigation_shell.dart';

// Name of background task
const String backgroundSyncTask = "com.vit.placement_watch.background_sync";

// Background callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Background WorkManager task started: $task");
    
    // Ensure plugin bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      // 1. Initialize notification system
      await NotificationService.instance.initialize();

      // 2. Fetch background OAuth headers
      final Map<String, String>? authHeaders = await AuthService.getHeadersForBackground();
      if (authHeaders == null) {
        debugPrint("Background sync skipped: Not authenticated.");
        return Future.value(true);
      }

      // 3. Fetch user settings from secure storage
      const secureStorage = FlutterSecureStorage();
      final String placementId = await secureStorage.read(key: AppConstants.keyPlacementId) ?? AppConstants.defaultPlacementId;
      final String cdcSender = await secureStorage.read(key: AppConstants.keyCdcSender) ?? AppConstants.defaultCdcSender;

      // 4. Check Gmail
      final gmailService = GmailService();
      final updates = await gmailService.fetchPlacementUpdates(
        authHeaders: authHeaders,
        placementId: placementId,
        cdcSender: cdcSender,
      );

      final dbHelper = DatabaseHelper.instance;
      
      // Determine if DB is empty to prevent spamming notifications on first load
      final existing = await dbHelper.getAllUpdates();
      final bool isFirstSync = existing.isEmpty;

      for (final update in updates) {
        final bool exists = await dbHelper.exists(update.gmailMessageId);
        if (!exists) {
          await dbHelper.insertUpdate(update);
          
          if (!isFirstSync) {
            // Trigger notification
            await NotificationService.instance.showNotification(
              id: Random().nextInt(100000),
              title: "🟢 New Shortlist: ${update.companyName}",
              body: update.emailSubject,
              payload: update.gmailMessageId,
            );
          }
        }
      }
      
      debugPrint("Background sync finished successfully.");
      return Future.value(true);
    } catch (e) {
      debugPrint("Background sync task failed: $e");
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService.instance.initialize();

  // Initialize WorkManager
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Register the periodic task
  await Workmanager().registerPeriodicTask(
    "1",
    backgroundSyncTask,
    frequency: const Duration(minutes: 15), // Run every 15 minutes
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep, // Avoid re-registering on every launch
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProxyProvider<AuthService, PlacementProvider>(
          create: (context) => PlacementProvider(
            Provider.of<AuthService>(context, listen: false),
          ),
          update: (context, authService, previousProvider) =>
              previousProvider ?? PlacementProvider(authService),
        ),
      ],
      child: MaterialApp(
        title: 'Placement Watch',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationShell(),
      ),
    );
  }
}
