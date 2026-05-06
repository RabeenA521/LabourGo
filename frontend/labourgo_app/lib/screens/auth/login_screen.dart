import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/social_auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/error_banner.dart';
import '../bookings/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading       = false;
  bool _obscure       = true;
  String? _error;

  Future<void> _onAuthSuccess(Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', result['tokens']['access']);
    await prefs.setString('refresh_token', result['tokens']['refresh']);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _socialLogin(Future<SocialAuthPayload> Function() signIn) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payload = await signIn();
      final result = await ApiService.socialLogin(
        provider: payload.provider,
        idToken: payload.idToken,
        accessToken: payload.accessToken,
        email: payload.email,
        fullName: payload.fullName,
      );
      if (result.containsKey('tokens')) {
        await _onAuthSuccess(result);
      } else {
        setState(() => _error = result['error'] ?? 'Login failed. Try again.');
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.toLowerCase().contains('cancelled')) {
        return;
      }
      setState(() => _error = msg.replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.login(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      if (result.containsKey('tokens')) {
        await _onAuthSuccess(result);
      } else {
        setState(() => _error = result['error'] ?? 'Login failed. Try again.');
      }
    } catch (e) {
      setState(() => _error = 'Cannot connect to server. Check your connection.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ── Top Blue Header ──────────────────────
              Container(
                width: double.infinity,
                height: 220,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.handyman_rounded,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'LabourGo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find trusted workers near you',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form ────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Text(
                      'Sign in to your account',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_error != null) ErrorBanner(message: _error!),

                    // Email
                    const Text('Email address',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'you@example.com',
                        prefixIcon: Icon(Icons.email_outlined,
                            color: AppColors.primary, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    const Text('Password',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.primary, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot password?',
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 13)),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Login button
                    AppButton(
                      text: 'Sign In',
                      onPressed: _login,
                      loading: _loading,
                      icon: Icons.login_rounded,
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 13)),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Social sign-in
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialCircleButton(
                          semanticLabel: 'Continue with Google',
                          icon: FaIcon(
                            FontAwesomeIcons.google,
                            size: 22,
                            color: const Color(0xFFDB4437),
                          ),
                          onPressed: _loading
                              ? null
                              : () => _socialLogin(SocialAuthService.signInWithGoogle),
                        ),
                        const SizedBox(width: 16),
                        _SocialCircleButton(
                          semanticLabel: 'Continue with Apple',
                          icon: FaIcon(
                            FontAwesomeIcons.apple,
                            size: 24,
                            color: Colors.black,
                          ),
                          onPressed: _loading
                              ? null
                              : () => _socialLogin(SocialAuthService.signInWithApple),
                        ),
                        const SizedBox(width: 16),
                        _SocialCircleButton(
                          semanticLabel: 'Continue with Facebook',
                          icon: FaIcon(
                            FontAwesomeIcons.facebookF,
                            size: 22,
                            color: const Color(0xFF1877F2),
                          ),
                          onPressed: _loading
                              ? null
                              : () => _socialLogin(SocialAuthService.signInWithFacebook),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Register button
                    AppButton(
                      text: 'Create New Account',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      outline: true,
                      icon: Icons.person_add_outlined,
                    ),

                    const SizedBox(height: 16),

                    // Terms
                    Center(
                      child: Text(
                        'By signing in, you agree to our Terms & Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  const _SocialCircleButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: disabled
                    ? AppColors.border.withValues(alpha: 0.6)
                    : AppColors.border,
                width: 1.2,
              ),
            ),
            alignment: Alignment.center,
            child: Opacity(opacity: disabled ? 0.5 : 1, child: icon),
          ),
        ),
      ),
    );
  }
}
