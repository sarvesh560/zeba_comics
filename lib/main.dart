import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_drive_reader_app/provider/theme_provider.dart';
import 'package:pdf_drive_reader_app/utils/wrapper_connectivity.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'features/auth/view_model/sign_in_view_model.dart';
import 'services/preferences_services.dart';
import 'features/splash/view/splash_screen_view.dart';
import 'features/library/view_model/favourite_view_model.dart';
import 'features/category/view_model/category_view_model.dart';
import 'features/main_screen/view/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // Load saved preferences
  final isSignedIn = await PreferencesService.getIsSignedIn();
  final savedDark = await PreferencesService.getDarkMode();
  final userInfo = await PreferencesService.getUserInfo();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(savedDark)),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()..fetchAll()),
        ChangeNotifierProvider(create: (_) => SignInViewModel()),
      ],
      child: MyApp(isSignedIn: isSignedIn, initialUserInfo: userInfo),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isSignedIn;
  final Map<String, String> initialUserInfo;

  const MyApp({
    super.key,
    required this.isSignedIn,
    required this.initialUserInfo,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Zeba Books',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: primarySwatch,
        colorScheme: ColorScheme.light(
          primary: primarySwatch,
          secondary: secondaryColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: primarySwatch,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: primarySwatch,
        colorScheme: ColorScheme.dark(
          primary: primarySwatch,
          secondary: secondaryColor,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: primarySwatch,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      // ✅ ConnectivityWrapper is inside MaterialApp
      home: ConnectivityWrapper(
        child: isSignedIn
            ? MainScreen(userInfo: initialUserInfo)
            : SplashScreen(),
      ),
    );
  }
}
