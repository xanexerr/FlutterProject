import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/current_user_service.dart';

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CurrentUserService _userService = CurrentUserService();
  
  Set<String> _favoriteProjects = {};
  Set<String> _favoriteInternships = {};

  FavoritesManager._internal();

  factory FavoritesManager() {
    return _instance;
  }

  /// Load favorites from Firestore
  Future<void> loadFavorites() async {
    try {
      final userId = _userService.getCurrentUserId();
      if (userId == null) return;

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        _favoriteProjects = Set<String>.from(data['favorites']?['projects'] ?? []);
        _favoriteInternships = Set<String>.from(data['favorites']?['internships'] ?? []);
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  /// Toggle favorite and save to Firestore
  Future<void> toggleFavorite(String id, {bool isProject = true}) async {
    try {
      final userId = _userService.getCurrentUserId();
      if (userId == null) return;

      final favoriteSet = isProject ? _favoriteProjects : _favoriteInternships;
      final key = isProject ? 'projects' : 'internships';

      if (favoriteSet.contains(id)) {
        favoriteSet.remove(id);
      } else {
        favoriteSet.add(id);
      }

      // Update in Firestore
      await _firestore.collection('users').doc(userId).update({
        'favorites.$key': favoriteSet.toList(),
      });
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  /// Get all favorite project IDs
  Set<String> get favoriteProjects => _favoriteProjects;

  /// Get all favorite internship IDs
  Set<String> get favoriteInternships => _favoriteInternships;

  /// Check if item is favorited
  bool isFavorite(String id, {bool isProject = true}) {
    return isProject 
        ? _favoriteProjects.contains(id)
        : _favoriteInternships.contains(id);
  }

  /// Remove all favorites
  void clear() {
    _favoriteProjects.clear();
    _favoriteInternships.clear();
  }
}
