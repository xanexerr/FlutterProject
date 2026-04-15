import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class CurrentUserService {
  static final CurrentUserService _instance = CurrentUserService._internal();

  factory CurrentUserService() {
    return _instance;
  }

  CurrentUserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _cachedUserData;
  String? _currentEmail; // Store email for login without Firebase Auth

  /// Set current user email (for login with Firestore password)
  void setCurrentUserEmail(String email) {
    _currentEmail = email;
  }

  /// Get the current logged-in user's ID (Firestore document ID)
  String? getCurrentUserId() {
    return _cachedUserData?.id;
  }

  /// Get the current logged-in user's email
  String? getCurrentUserEmail() {
    return _currentEmail ?? _cachedUserData?.email;
  }

  /// Get cached user name
  String? getCachedUserName() {
    return _cachedUserData?.full_name ?? 'User';
  }

  /// Fetch and cache user data from Firestore (same as profile_screen)
  Future<UserModel?> fetchCurrentUserData({String? email}) async {
    try {
      final userEmail = email ?? _currentEmail;
      if (userEmail == null) return null;

      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (query.docs.isNotEmpty) {
        var doc = query.docs.first;
        _cachedUserData = UserModel.fromJson(doc.data(), doc.id);
        _currentEmail = userEmail;
        return _cachedUserData;
      }
    } catch (e) {
      print('Error fetching current user data: $e');
    }
    return null;
  }

  /// Get cached user data
  UserModel? getCachedUserData() {
    return _cachedUserData;
  }

  /// Clear cached data on logout
  void clearCache() {
    _cachedUserData = null;
    _currentEmail = null;
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _cachedUserData != null || _currentEmail != null;
  }

  /// Sign out and clear cache
  Future<void> signOut() async {
    clearCache();
  }
}

