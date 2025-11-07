import 'package:flutter/material.dart';
import '../repo/sign_in_repo.dart';

class SignInViewModel extends ChangeNotifier {
  final SignInRepo _repo = SignInRepo();
  bool isLoading = false;

  /// Sign in using Google
  Future<Map<String, String>?> signInWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();
      final user = await _repo.googleSignIn();
      if (user != null) {
        await _repo.saveUserPrefs(user['name']!, user['email']!, user['photo']!);
        return user;
      }
    } catch (e) {
      debugPrint("Google Sign-in Error: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// Manual sign-in using email & password (no validation)
  Future<Map<String, String>?> manualSignIn(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      // Create a user object directly, no validation
      final user = {"name": "User", "email": email, "photo": ""};
      await _repo.saveUserPrefs(user['name']!, user['email']!, user['photo']!);

      return user;
    } catch (e) {
      debugPrint("Manual Sign-in Error: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
