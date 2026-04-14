import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUserService {
  static final CurrentUserService _instance = CurrentUserService._internal();

  factory CurrentUserService() {
    return _instance;
  }

  CurrentUserService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _cachedUserData;
  String? _cachedUserName;

  /// Get the current logged-in user's ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Get the current logged-in user's email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Get cached user name (from previous login)
  String? getCachedUserName() {
    return _cachedUserName;
  }

  /// Fetch and cache user data from Firestore
  Future<Map<String, dynamic>?> fetchCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        _cachedUserData = userDoc.data();
        _cachedUserName = _cachedUserData?['full_name'] ?? 'User';
        return _cachedUserData;
      }
    } catch (e) {
      print('Error fetching current user data: $e');
    }
    return null;
  }

  /// Get cached user data
  Map<String, dynamic>? getCachedUserData() {
    return _cachedUserData;
  }

  /// Clear cached data on logout
  void clearCache() {
    _cachedUserData = null;
    _cachedUserName = null;
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  /// Sign out and clear cache
  Future<void> signOut() async {
    clearCache();
    await _auth.signOut();
  }
}
