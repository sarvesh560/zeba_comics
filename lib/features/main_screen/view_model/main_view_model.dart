import 'package:flutter/material.dart';
import '../../home/view/drive_dashboard_screen.dart';
import '../../category/view/category_view.dart';
import '../../library/view/library_screen.dart';

class MainViewModel extends ChangeNotifier {
  int currentIndex = 0;

  final Map<String, String> userInfo;
  final bool isDark;
  final Function(bool) onToggleTheme;

  MainViewModel({
    required this.userInfo,
    required this.isDark,
    required this.onToggleTheme,
  });

  late final List<Widget> screens = [
    const DriveDashboardScreen(),
    const CategoryPage(),
    LibraryPage(),
    const Center(child: Text("Profile")),
  ];

  void setIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
