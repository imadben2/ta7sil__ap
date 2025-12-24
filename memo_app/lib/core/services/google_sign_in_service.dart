import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for handling Google Sign-In
class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Initiate Google Sign-In and return result with ID token
  static Future<GoogleSignInResult> signIn() async {
    try {
      // Sign out first to ensure fresh login
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();

      if (account == null) {
        return GoogleSignInResult.cancelled();
      }

      final auth = await account.authentication;

      if (auth.idToken == null) {
        return GoogleSignInResult.error('لم نتمكن من الحصول على رمز التحقق');
      }

      return GoogleSignInResult.success(
        idToken: auth.idToken!,
        accessToken: auth.accessToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } on PlatformException catch (e) {
      // Handle configuration errors specifically
      if (e.code == 'channel-error' || e.message?.contains('GoogleSignInApi') == true) {
        return GoogleSignInResult.error(
          'خدمة Google Sign-In غير مُهيأة بشكل صحيح. يرجى التواصل مع الدعم الفني.',
        );
      }
      return GoogleSignInResult.error('خطأ في تسجيل الدخول: ${e.message}');
    } catch (e) {
      // Handle generic errors with user-friendly message
      final errorStr = e.toString();
      if (errorStr.contains('PlatformException') || errorStr.contains('channel-error')) {
        return GoogleSignInResult.error(
          'خدمة Google Sign-In غير مُهيأة بشكل صحيح. يرجى التواصل مع الدعم الفني.',
        );
      }
      return GoogleSignInResult.error('حدث خطأ أثناء تسجيل الدخول بحساب Google');
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Disconnect from Google (revokes access)
  static Future<void> disconnect() async {
    await _googleSignIn.disconnect();
  }

  /// Check if currently signed in
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get current signed-in account (if any)
  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}

/// Result class for Google Sign-In operation
class GoogleSignInResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? errorMessage;

  GoogleSignInResult._({
    required this.isSuccess,
    required this.isCancelled,
    this.idToken,
    this.accessToken,
    this.email,
    this.displayName,
    this.photoUrl,
    this.errorMessage,
  });

  /// Create a successful result
  factory GoogleSignInResult.success({
    required String idToken,
    String? accessToken,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return GoogleSignInResult._(
      isSuccess: true,
      isCancelled: false,
      idToken: idToken,
      accessToken: accessToken,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  /// Create a cancelled result (user dismissed the dialog)
  factory GoogleSignInResult.cancelled() {
    return GoogleSignInResult._(
      isSuccess: false,
      isCancelled: true,
    );
  }

  /// Create an error result
  factory GoogleSignInResult.error(String message) {
    return GoogleSignInResult._(
      isSuccess: false,
      isCancelled: false,
      errorMessage: message,
    );
  }
}
