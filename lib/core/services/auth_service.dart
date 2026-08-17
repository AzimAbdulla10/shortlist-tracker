import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/constants.dart';

class AuthService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: AppConstants.gmailScopes,
  );
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  GoogleSignInAccount? _currentUser;
  bool _isLoading = true;

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;
      notifyListeners();
    });
    
    try {
      // Attempt silent sign-in on app start
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        await _secureStorage.write(key: AppConstants.keyUserEmail, value: _currentUser!.email);
      }
    } catch (e) {
      debugPrint("Silent sign in error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get authenticated headers
  Future<Map<String, String>?> getAuthHeaders() async {
    if (_currentUser == null) {
      // Try to recover silently
      _currentUser = await _googleSignIn.signInSilently();
    }
    return await _currentUser?.authHeaders;
  }

  // Login
  Future<bool> login() async {
    _isLoading = true;
    notifyListeners();
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        _currentUser = account;
        await _secureStorage.write(key: AppConstants.keyUserEmail, value: account.email);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Login error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _googleSignIn.signOut();
      await _secureStorage.delete(key: AppConstants.keyUserEmail);
      _currentUser = null;
    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Silent sign-in method for background worker
  static Future<Map<String, String>?> getHeadersForBackground() async {
    final googleSignIn = GoogleSignIn(scopes: AppConstants.gmailScopes);
    try {
      final account = await googleSignIn.signInSilently();
      return await account?.authHeaders;
    } catch (e) {
      debugPrint("Background silent sign-in failed: $e");
      return null;
    }
  }

  // Helper to read setting from secure storage
  Future<String> getPlacementId() async {
    final value = await _secureStorage.read(key: AppConstants.keyPlacementId);
    return value ?? AppConstants.defaultPlacementId;
  }

  // Helper to write setting to secure storage
  Future<void> setPlacementId(String id) async {
    await _secureStorage.write(key: AppConstants.keyPlacementId, value: id);
    notifyListeners();
  }

  // Helper to read CDC sender
  Future<String> getCdcSender() async {
    final value = await _secureStorage.read(key: AppConstants.keyCdcSender);
    return value ?? AppConstants.defaultCdcSender;
  }

  // Helper to write CDC sender
  Future<void> setCdcSender(String sender) async {
    await _secureStorage.write(key: AppConstants.keyCdcSender, value: sender);
    notifyListeners();
  }

  // Helper to read custom role
  Future<String> getCustomRole() async {
    final value = await _secureStorage.read(key: AppConstants.keyCustomRole);
    return value ?? "Senior Tracking Engineer";
  }

  // Helper to write custom role
  Future<void> setCustomRole(String role) async {
    await _secureStorage.write(key: AppConstants.keyCustomRole, value: role);
    notifyListeners();
  }

  // Helper to read custom client ID
  Future<String> getCustomClientId() async {
    final value = await _secureStorage.read(key: AppConstants.keyCustomClientId);
    return value ?? "PT-8492-X";
  }

  // Helper to write custom client ID
  Future<void> setCustomClientId(String id) async {
    await _secureStorage.write(key: AppConstants.keyCustomClientId, value: id);
    notifyListeners();
  }
}
