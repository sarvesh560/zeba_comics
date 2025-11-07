import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_values.dart';
import '../../../provider/theme_provider.dart';
import '../../auth/view/sign_in_screen.dart';
import '../view_model/profile_view_model.dart';
import 'edit_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;

    final themeProvider = Provider.of<ThemeProvider>(context);

    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: themeProvider.isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            appBar: AppBar(
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: themeProvider.isDark
                        ? [Colors.blueGrey.shade700, Colors.blueGrey.shade900]
                        : [AppColors.primaryStart, AppColors.primaryEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: Text(
                'Profile',
                style: AppTextStyles.heading(screenWidth * 0.06, color: AppColors.white),
              ),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(18))),
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05, vertical: screenHeight * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vm.userName,
                    style: AppTextStyles.subHeading(screenWidth * 0.05,
                        color: themeProvider.isDark
                            ? AppColors.white
                            : AppColors.black),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Text(
                    vm.userEmail,
                    style: AppTextStyles.body(screenWidth * 0.038,
                        color: themeProvider.isDark
                            ? Colors.white70
                            : AppColors.greyDark),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  _buildActionCard(
                    context,
                    icon: Icons.edit,
                    title: 'Edit Name',
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          title: 'Edit Name',
                          initialValue: vm.userName,
                          onSave: vm.updateName,
                        ),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.lock,
                    title: 'Edit Password',
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          title: 'Edit Password',
                          initialValue: '',
                          obscureText: true,
                          onSave: vm.updatePassword,
                        ),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.email,
                    title: 'Contact Us',
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Contact Email'),
                        content: const Text('letters@zebabooks.org'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'))
                        ],
                      ),
                    ),
                  ),
                  _buildDarkModeCard(context, screenWidth, screenHeight, themeProvider),
                  _buildActionCard(
                    context,
                    icon: Icons.logout,
                    title: 'Sign Out',
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onTap: () async {
                      await vm.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SignInScreen()),
                      );
                    },
                    gradient: LinearGradient(
                        colors: themeProvider.isDark
                            ? [Colors.blueGrey.shade700, Colors.blueGrey.shade900]
                            : [AppColors.primaryStart, AppColors.primaryEnd]),
                    iconColor: AppColors.white,
                    textColor: AppColors.white,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required double screenWidth,
        required double screenHeight,
        required VoidCallback onTap,
        Gradient? gradient,
        Color iconColor = AppColors.primaryStart,
        Color textColor = AppColors.black,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
        decoration: BoxDecoration(
            gradient: gradient ??
                const LinearGradient(colors: [AppColors.white, AppColors.white]),
            borderRadius: BorderRadius.circular(AppValues.radiusLarge),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6))
            ]),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: screenWidth * 0.065),
            SizedBox(width: screenWidth * 0.04),
            Text(title,
                style: AppTextStyles.subHeading(screenWidth * 0.045, color: textColor))
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeCard(
      BuildContext context, double screenWidth, double screenHeight, ThemeProvider themeProvider) {
    final isDark = themeProvider.isDark;
    final gradientStart = isDark ? Colors.blueGrey.shade700 : AppColors.primaryStart;
    final gradientEnd = isDark ? Colors.blueGrey.shade900 : AppColors.primaryEnd;

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(AppValues.radiusLarge),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? gradientEnd : gradientStart, size: screenWidth * 0.065),
              SizedBox(width: screenWidth * 0.04),
              Text('Dark Mode',
                  style: AppTextStyles.subHeading(screenWidth * 0.045,
                      color: isDark ? AppColors.white : AppColors.black))
            ],
          ),
          Switch(
            value: isDark,
            activeTrackColor: gradientEnd.withOpacity(0.5),
            activeColor: gradientEnd,
            inactiveTrackColor: gradientStart.withOpacity(0.3),
            onChanged: (v) => themeProvider.toggleTheme(v),
          ),
        ],
      ),
    );
  }
}
