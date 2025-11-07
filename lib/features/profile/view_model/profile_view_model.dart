import 'package:flutter/material.dart';

import '../../auth/repo/sign_in_repo.dart';

class ProfileViewModel extends ChangeNotifier {
  final SignInRepo _repo = SignInRepo();

  String userName = '';
  String userEmail = '';
  String userPhoto = '';

  bool isLoading = false;

  ProfileViewModel() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading = true;
    notifyListeners();

    final prefs = await _repo.getUserPrefs();
    userName = prefs?['name'] ?? '';
    userEmail = prefs?['email'] ?? '';
    userPhoto = prefs?['photo'] ?? '';

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    userName = newName;
    await _repo.saveUserPrefs(userName, userEmail, userPhoto);
    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    // Save new password if needed (here we skip validation/storage for demo)
    debugPrint('Password updated: $newPassword');
  }

  Future<void> signOut() async {
    await _repo.signOut();
    userName = '';
    userEmail = '';
    userPhoto = '';
    notifyListeners();
  }
}
