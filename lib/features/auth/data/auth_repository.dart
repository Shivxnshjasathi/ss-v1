import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository(this._auth);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(FirebaseAuthException e) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    LoggerService.i('Auth: Started verifyPhoneNumber for $phoneNumber');
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (cred) {
        LoggerService.i('Auth: Auto verification completed');
        verificationCompleted(cred);
      },
      verificationFailed: (e) {
        LoggerService.e('Auth: Verification Failed: ${e.code}', error: e);
        verificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        LoggerService.i('Auth: Code Sent ID: $verificationId');
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    LoggerService.i('Auth: Verifying OTP...');
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final cred = await _auth.signInWithCredential(credential);
      LoggerService.i('Auth: OTP Verification Success. UID: ${cred.user?.uid}');
      return cred;
    } catch (e, st) {
      LoggerService.e('Auth: OTP Verification Error', error: e, stack: st);
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    LoggerService.i('Auth: Signing in with Email: $email');
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      LoggerService.i('Auth: Sign in success. UID: ${cred.user?.uid}');
      return cred;
    } catch (e, st) {
      LoggerService.e('Auth: Sign in error', error: e, stack: st);
      rethrow;
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    LoggerService.i('Auth: Creating user with Email: $email');
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      LoggerService.i('Auth: Creation success. UID: ${cred.user?.uid}');
      return cred;
    } catch (e, st) {
      LoggerService.e('Auth: Creation error', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    LoggerService.w('Auth: Signing out');
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    LoggerService.i('Auth: Sending password reset email to $email');
    try {
      await _auth.sendPasswordResetEmail(email: email);
      LoggerService.i('Auth: Password reset email sent successfully');
    } catch (e, st) {
      LoggerService.e('Auth: Error sending password reset email', error: e, stack: st);
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      LoggerService.i('Auth: Starting Google Sign In');
      
      // Explicitly pass the web client ID from google-services.json (client_type: 3)
      // to prevent DEVELOPER_ERROR on Android.
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '987957373561-166rstgm0sr92vu36evpqe5j80qgdkuq.apps.googleusercontent.com',
        scopes: ['email'],
      );
      
      // Sign out first to ensure a clean session and force account picker
      await googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        LoggerService.w('Auth: Google Sign In cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      LoggerService.i('Auth: Google Sign In Success. UID: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e, st) {
      LoggerService.e('Auth: Error during Google sign in', error: e, stack: st);
      rethrow;
    }
  }
}
