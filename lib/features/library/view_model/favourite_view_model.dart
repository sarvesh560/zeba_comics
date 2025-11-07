import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/model/drive_file_model.dart';

class FavoritesViewModel extends ChangeNotifier {
  static const _favoritesKey = "favoritesList";
  final List<DriveFileModel> _favorites = [];

  FavoritesViewModel() {
    _loadFavorites();
  }

  /// Load saved favorites on startup
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_favoritesKey);
    if (jsonStr != null) {
      final List decoded = json.decode(jsonStr);
      _favorites
        ..clear()
        ..addAll(decoded.map((e) => DriveFileModel.fromJson(e)));
      notifyListeners();
    }
  }

  /// Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _favorites.map((file) => file.toJson()).toList();
    await prefs.setString(_favoritesKey, json.encode(jsonList));
  }

  /// Add or remove favorite, show SnackBar
  void toggleFavorite(DriveFileModel file, BuildContext context) {
    final exists = _favorites.any((f) => f.id == file.id);
    String message;

    if (exists) {
      _favorites.removeWhere((f) => f.id == file.id);
      message = '"${file.name}" removed from favorites';
    } else {
      _favorites.add(file);
      message = '"${file.name}" added to favorites';
    }

    _saveFavorites();
    notifyListeners();

    // Show SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Check if file is favorite
  bool isFavorite(DriveFileModel file) => _favorites.any((f) => f.id == file.id);

  /// Get all favorites
  List<DriveFileModel> get favorites => List.unmodifiable(_favorites);

  /// Optional: clear all favorites (e.g. on logout)
  Future<void> clearFavorites() async {
    _favorites.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
    notifyListeners();
  }
}
