class SocialAuthPayload {
  const SocialAuthPayload({
    required this.provider,
    this.idToken,
    this.accessToken,
    this.email,
    this.fullName,
  });

  final String provider;
  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? fullName;
}

class SocialAuthService {
  static Future<SocialAuthPayload> signInWithGoogle() async {
    throw UnimplementedError('Google sign-in not implemented.');
  }

  static Future<SocialAuthPayload> signInWithApple() async {
    throw UnimplementedError('Apple sign-in not implemented.');
  }

  static Future<SocialAuthPayload> signInWithFacebook() async {
    throw UnimplementedError('Facebook sign-in not implemented.');
  }
}
