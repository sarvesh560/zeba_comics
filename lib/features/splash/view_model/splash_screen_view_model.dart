import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/theme_provider.dart';
import '../../../services/preferences_services.dart';
import '../../auth/view/sign_in_screen.dart';
import '../../auth/view_model/sign_in_view_model.dart';
import '../../main_screen/view/main_screen.dart';

class SplashViewModel {
  void handleNavigation({required BuildContext context}) async {
    await Future.delayed(const Duration(seconds: 3));

    final isSignedIn = await PreferencesService.getIsSignedIn();
    final userInfo = isSignedIn
        ? await PreferencesService.getUserInfo()
        : {"name": "Guest", "email": "guest@example.com"};

    if (!context.mounted) return;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (isSignedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            userInfo: userInfo,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => SignInViewModel(),
            child: const SignInScreen(),
          ),
        ),
      );
    }
  }
}
