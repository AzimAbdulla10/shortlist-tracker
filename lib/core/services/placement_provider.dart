import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/placement_update.dart';
import '../database/db_helper.dart';
import 'auth_service.dart';
import 'gmail_service.dart';
import 'notification_service.dart';

class PlacementProvider extends ChangeNotifier {
  final AuthService _authService;
  final GmailService _gmailService = GmailService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<PlacementUpdate> _updates = [];
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  String? _errorMessage;

  List<PlacementUpdate> get updates => _updates;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;

  PlacementProvider(this._authService) {
    // Load local history initially
    loadHistory();
  }

  // Load from local database
  Future<void> loadHistory() async {
    try {
      _updates = await _dbHelper.getAllUpdates();
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to load local history: $e";
      notifyListeners();
    }
  }

  // Run synchronization
  Future<void> syncData() async {
    if (_isSyncing) return;
    if (!_authService.isAuthenticated) {
      _errorMessage = "Google Account not authenticated.";
      notifyListeners();
      return;
    }

    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _authService.getAuthHeaders();
      if (headers == null) {
        throw Exception("Could not fetch OAuth auth headers.");
      }

      final placementId = await _authService.getPlacementId();
      final cdcSender = await _authService.getCdcSender();

      // Fetch from Gmail API
      final gmailUpdates = await _gmailService.fetchPlacementUpdates(
        authHeaders: headers,
        placementId: placementId,
        cdcSender: cdcSender,
      );

      // Check if DB is empty to detect "first sync"
      final existingUpdates = await _dbHelper.getAllUpdates();
      final bool isFirstSync = existingUpdates.isEmpty;

      int newUpdatesCount = 0;
      for (final update in gmailUpdates) {
        final bool exists = await _dbHelper.exists(update.gmailMessageId);
        if (!exists) {
          await _dbHelper.insertUpdate(update);
          newUpdatesCount++;

          // Trigger notification only if it is NOT the first sync
          if (!isFirstSync) {
            await NotificationService.instance.showNotification(
              id: Random().nextInt(100000),
              title: "🟢 New Shortlist: ${update.companyName}",
              body: update.emailSubject,
              payload: update.gmailMessageId,
            );
          }
        }
      }

      debugPrint("Synced $newUpdatesCount new updates.");
      // Reload from local storage
      await loadHistory();
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _errorMessage = "Sync failed: $e";
      debugPrint("Sync Error: $e");
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Clear data (e.g. on logout)
  Future<void> clearAll() async {
    await _dbHelper.clearDatabase();
    _updates = [];
    _lastSyncTime = null;
    _errorMessage = null;
    notifyListeners();
  }
}
