import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../view_model/splash_screen_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashViewModel _viewModel = SplashViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.handleNavigation(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/zeba_logo.png',
              height: screenHeight * 0.2,
              width: screenWidth * 0.35,
              fit: BoxFit.contain,
            )
                .animate()
                .fadeIn(duration: 1200.ms)
                .scale(delay: 300.ms),

            SizedBox(height: screenHeight * 0.03),

            Text(
              "Zeba Books",
              style: AppTextStyles.heading(
                screenWidth * 0.08,
                color: AppColors.black,
              ),
            ).animate().fadeIn(delay: 600.ms),

            SizedBox(height: screenHeight * 0.015),

            SizedBox(
              width: screenWidth * 0.45,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.black.withOpacity(0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ).animate().fadeIn(delay: 1400.ms),
          ],
        ),
      ),
    );
  }
}
