class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  final Set<String> _favorites = {};

  FavoritesManager._internal();

  factory FavoritesManager() {
    return _instance;
  }

  Set<String> get favorites => _favorites;

  bool isFavorite(String projectId) {
    return _favorites.contains(projectId);
  }

  void toggleFavorite(String projectId) {
    if (_favorites.contains(projectId)) {
      _favorites.remove(projectId);
    } else {
      _favorites.add(projectId);
    }
  }

  void addFavorite(String projectId) {
    _favorites.add(projectId);
  }

  void removeFavorite(String projectId) {
    _favorites.remove(projectId);
  }

  List<String> getFavoritesList() {
    return _favorites.toList();
  }

  int get count => _favorites.length;

  void clear() {
    _favorites.clear();
  }
}
