import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/bookings/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LabourGoApp());
}

class LabourGoApp extends StatelessWidget {
  const LabourGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabourGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) =>
              token != null ? const HomeScreen() : const LoginScreen(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.handyman_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'LabourGo',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Your trusted labour platform',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Loading dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: i == 0 ? 1.0 : 0.4),
                          shape: BoxShape.circle,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
