import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

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
    debugPrint('🔥 [AuthRepository] Started verifyPhoneNumber for $phoneNumber');
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (cred) {
        debugPrint('🔥 [AuthRepository] Auto verification completed!');
        verificationCompleted(cred);
      },
      verificationFailed: (e) {
        debugPrint('🔥 [AuthRepository] Verification Failed: ${e.code}');
        verificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        debugPrint('🔥 [AuthRepository] Code Sent! ID: $verificationId');
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
    debugPrint('🔥 [AuthRepository] Verifying OTP...');
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final cred = await _auth.signInWithCredential(credential);
      debugPrint('✅ [AuthRepository] OTP Verification Success. UID: ${cred.user?.uid}');
      return cred;
    } catch (e, st) {
      debugPrint('❌ [AuthRepository] OTP Verification Error: $e\n$st');
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    debugPrint('🔥 [AuthRepository] Signing in with Email: $email');
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      debugPrint('✅ [AuthRepository] Sign in success. UID: ${cred.user?.uid}');
      return cred;
    } catch (e, st) {
      debugPrint('❌ [AuthRepository] Sign in error: $e\n$st');
      rethrow;
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    debugPrint('🔥 [AuthRepository] Creating user with Email: $email');
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      debugPrint('✅ [AuthRepository] Creation success. UID: ${cred.user?.uid}');
      return cred;
    } catch (e, st) {
      debugPrint('❌ [AuthRepository] Creation error: $e\n$st');
      rethrow;
    }
  }

  Future<void> signOut() async {
    debugPrint('🔥 [AuthRepository] Signing out');
    await _auth.signOut();
  }
}
