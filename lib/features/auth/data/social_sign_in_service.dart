import 'package:google_sign_in/google_sign_in.dart';
import 'package:rekognita_app/features/auth/data/social_identity.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialSignInService {
  SocialSignInService({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: const ['email']);

  final GoogleSignIn _googleSignIn;

  Future<SocialIdentity> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw SocialSignInException('Google sign-in was cancelled');
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw SocialSignInException('Google did not return an ID token');
    }

    return SocialIdentity(
      provider: 'google',
      idToken: idToken,
      email: account.email,
      fullName: account.displayName,
    );
  }

  Future<SocialIdentity> signInWithApple() async {
    final available = await SignInWithApple.isAvailable();
    if (!available) {
      throw SocialSignInException(
        'Apple Sign-In is not available on this device',
      );
    }

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final idToken = credential.identityToken;
    if (idToken == null || idToken.isEmpty) {
      throw SocialSignInException('Apple did not return an identity token');
    }

    final givenName = credential.givenName?.trim();
    final familyName = credential.familyName?.trim();
    final fullName = [
      givenName,
      familyName,
    ].where((part) => part != null && part.isNotEmpty).join(' ').trim();

    return SocialIdentity(
      provider: 'apple',
      idToken: idToken,
      email: credential.email,
      fullName: fullName.isEmpty ? null : fullName,
    );
  }
}

class SocialSignInException implements Exception {
  SocialSignInException(this.message);

  final String message;

  @override
  String toString() => message;
}
