import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInRepo {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  /// Google Sign-In
  Future<Map<String, String>?> googleSignIn() async {
    final account = await _googleSignIn.signIn();
    if (account != null) {
      return {
        'name': account.displayName ?? 'Google User',
        'email': account.email,
        'photo': account.photoUrl ?? '',
      };
    }
    return null;
  }

  /// Save user info locally
  Future<void> saveUserPrefs(String name, String email, String photo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedIn', true);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userPhoto', photo);
  }

  /// Get saved user info
  Future<Map<String, String>> getUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('userName') ?? 'Guest',
      'email': prefs.getString('userEmail') ?? '',
      'photo': prefs.getString('userPhoto') ?? '',
    };
  }

  /// Sign out (clears local prefs and Google sign-in)
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // clears all saved prefs
    try {
      await _googleSignIn.signOut(); // also sign out from Google
    } catch (e) {
      // ignore if user never signed in with Google
    }
  }
}
