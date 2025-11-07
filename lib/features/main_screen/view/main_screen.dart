import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../provider/theme_provider.dart';
import '../../category/view/category_view.dart';
import '../../home/view/drive_dashboard_screen.dart';
import '../../library/view/library_screen.dart';
import '../../profile/view/profile_view.dart';

class MainScreen extends StatefulWidget {
  final Map<String, String> userInfo;
  const MainScreen({super.key, required this.userInfo});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  bool hasConnection = true;

  @override
  void initState() {
    super.initState();

    _pages = [
      DriveDashboardScreen(),
      const CategoryPage(),
      LibraryPage(),
      const ProfileScreen(),
    ];

    // Transparent status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _initConnectivity();

    // Listen for connectivity changes safely
    Connectivity()
        .onConnectivityChanged
        .map((event) {
      // If event is a list, take the first element; otherwise return event
      return event.isNotEmpty ? event.first : ConnectivityResult.none;
        })
        .listen((status) {
      _updateConnection(status);
    });
  }


  Future<void> _initConnectivity() async {
    // Give time for network to initialize
    await Future.delayed(const Duration(seconds: 1));

    try {
      final result = await InternetAddress.lookup('example.com');
      setState(() {
        hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      });
    } catch (_) {
      setState(() => hasConnection = false);
    }
  }

  void _updateConnection(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      setState(() => hasConnection = false);
    } else {
      // Double-check actual internet
      try {
        final lookup = await InternetAddress.lookup('example.com');
        setState(() {
          hasConnection = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
        });
      } catch (_) {
        setState(() => hasConnection = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;

    final iconSize = screenWidth * 0.065;
    final fontSize = screenWidth * 0.032;
    final navBarHeight = screenHeight * 0.075;
    final paddingVertical = screenHeight * 0.012;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    final selectedColor = AppColors.primaryStart;
    final unselectedColor = isDark ? Colors.white70 : AppColors.greyDark;
    final backgroundColor = isDark ? AppColors.cardDark : AppColors.white;

    final icons = [
      Icons.home,
      Icons.category,
      Icons.book,
      Icons.person_outline_outlined
    ];
    final labels = ["Home", "Categories", "Library", "Profile"];

    // Show no internet overlay if disconnected
    if (!hasConnection) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            "No Internet Connection",
            style: AppTextStyles.heading(screenWidth * 0.05, color: isDark ? Colors.white : Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.white,
      body: _pages[_currentIndex],
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.01,
        ),
        child: Container(
          height: navBarHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: List.generate(4, (index) {
              final isSelected = _currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(vertical: paddingVertical),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            icons[index],
                            size: iconSize,
                            color: isSelected ? selectedColor : unselectedColor,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              labels[index],
                              style: AppTextStyles.body(
                                fontSize,
                                color: isSelected ? selectedColor : unselectedColor,
                                weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
