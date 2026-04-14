import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class CurrentUserService {
  static final CurrentUserService _instance = CurrentUserService._internal();

  factory CurrentUserService() {
    return _instance;
  }

  CurrentUserService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _cachedUserData;

  /// Get the current logged-in user's ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Get the current logged-in user's email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Get cached user name
  String? getCachedUserName() {
    return _cachedUserData?.full_name ?? 'User';
  }

  /// Fetch and cache user data from Firestore (same as profile_screen)
  Future<UserModel?> fetchCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return null;

      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email!)
          .get();

      if (query.docs.isNotEmpty) {
        var doc = query.docs.first;
        _cachedUserData = UserModel.fromJson(doc.data(), doc.id);
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

