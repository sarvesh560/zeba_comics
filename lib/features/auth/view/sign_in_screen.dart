import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_drive_reader_app/features/main_screen/view/main_screen.dart';
import 'package:provider/provider.dart';
import '../view_model/sign_in_view_model.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7)
        .animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SignInViewModel>(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final spacing = height * 0.02;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: Column(
            children: [
              Hero(
                tag: "app_logo",
                child: Image.asset(
                  'assets/images/zeba_logo.png',
                  height: height * 0.12,
                ),
              ).animate().fadeIn(duration: 900.ms),

              SizedBox(height: spacing),
              Text(
                "Welcome Back 👋",
                style: GoogleFonts.firaSans(
                  fontSize: width * 0.05,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: spacing),

              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.all(width * 0.05),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue.shade50],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(_glowAnimation.value),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            _emailController,
                            "Email",
                            Icons.email,
                            false,
                                (v) {
                              if (v == null || v.isEmpty) return "Email cannot be empty";
                              final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!regex.hasMatch(v)) return "Enter a valid email";
                              return null;
                            },
                          ),
                          SizedBox(height: spacing),
                          _buildTextField(
                            _passwordController,
                            "Password",
                            Icons.lock,
                            true,
                                (v) {
                              if (v == null || v.isEmpty) return "Password cannot be empty";
                              if (v.length < 6) return "At least 6 characters";
                              final regex = RegExp(r'^(?=.*[!@#\$&*~]).{6,}$');
                              if (!regex.hasMatch(v)) return "Include 1 special character";
                              return null;
                            },
                          ),
                          SizedBox(height: spacing),
                          vm.isLoading
                              ? const CircularProgressIndicator()
                              : _buildButton("Sign In", () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                final user = await vm.manualSignIn(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                                if (mounted && user != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MainScreen(userInfo: user),
                                    ),
                                  );
                                }
                              } catch (e) {
                                _showError(e.toString());
                              }
                            }
                          }, width, height),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 700.ms);
                },
              ),

              SizedBox(height: spacing * 2),
              Text(
                "Or continue with",
                style: GoogleFonts.firaSans(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: spacing),
              _buildSocialButton(
                'assets/images/google_logo.png',
                "Google",
                    () async {
                  try {
                    final user = await vm.signInWithGoogle();
                    if (mounted && user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MainScreen(userInfo: user)),
                      );
                    }
                  } catch (e) {
                    _showError("Google Sign-in failed: $e");
                  }
                },
                Colors.redAccent,
                Colors.orangeAccent,
                width,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon,
      bool obscure,
      String? Function(String?) validator,
      ) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.firaSans(),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap, double width, double height) {
    return SizedBox(
      width: double.infinity,
      height: height * 0.065,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
        ),
        child: Text(
          text,
          style: GoogleFonts.firaSans(
            fontWeight: FontWeight.bold,
            fontSize: width * 0.045,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
      String iconPath,
      String text,
      VoidCallback onTap,
      Color start,
      Color end,
      double width,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: width * 0.035),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [start, end]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: start.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: width * 0.06),
            SizedBox(width: width * 0.03),
            Text(
              text,
              style: GoogleFonts.firaSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: width * 0.04,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
    );
  }
}
