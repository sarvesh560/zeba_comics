import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_values.dart';
import '../../../provider/theme_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final String title;
  final String initialValue;
  final bool obscureText;
  final Future<void> Function(String) onSave;

  const EditProfileScreen({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onSave,
    this.obscureText = false,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final fieldColor = isDark ? AppColors.cardDark : AppColors.white;
    final textColor = isDark ? AppColors.white : AppColors.black;
    final hintColor = isDark ? Colors.white60 : AppColors.greyDark;
    final gradientStart = isDark ? Colors.blueGrey.shade700 : AppColors.primaryStart;
    final gradientEnd = isDark ? Colors.blueGrey.shade900 : AppColors.primaryEnd;
    final shadowColor = isDark ? gradientStart.withOpacity(0.25) : Colors.grey.withOpacity(0.2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [gradientStart, gradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        title: Text(widget.title, style: AppTextStyles.heading(screenWidth * 0.06, color: AppColors.white)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(AppValues.radiusLarge),
                    boxShadow: [BoxShadow(color: shadowColor, blurRadius: isDark ? 18 : 10, offset: const Offset(0, 5))],
                    border: Border.all(color: gradientStart.withOpacity(_glowAnimation.value * 0.8), width: 1.3),
                  ),
                  child: TextField(
                    controller: _controller,
                    obscureText: widget.obscureText,
                    cursorColor: gradientStart,
                    style: AppTextStyles.body(screenWidth * 0.045, color: textColor, weight: FontWeight.w500),
                    decoration: InputDecoration(
                      labelText: widget.title,
                      labelStyle: AppTextStyles.body(screenWidth * 0.04, color: hintColor),
                      border: InputBorder.none,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: screenHeight * 0.05),
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.065,
                  child: ElevatedButton(
                    onPressed: () async {
                      await widget.onSave(_controller.text.trim());
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppValues.radiusLarge)),
                      padding: EdgeInsets.zero,
                      elevation: 12,
                      backgroundColor: Colors.transparent,
                      shadowColor: shadowColor,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(gradientStart, gradientEnd, _glowAnimation.value)!,
                            Color.lerp(gradientEnd, gradientStart, _glowAnimation.value)!
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppValues.radiusLarge),
                      ),
                      child: Center(
                        child: Text('Save',
                            style: AppTextStyles.subHeading(screenWidth * 0.045, color: AppColors.white)),
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
