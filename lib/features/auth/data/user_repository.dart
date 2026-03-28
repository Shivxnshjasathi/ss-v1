import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../domain/user_model.dart';
import 'auth_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

final currentUserDataProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUser(user.uid);
});

final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, uid) async {
  if (uid.isEmpty) return null;
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUser(uid);
});

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<void> saveUser(UserModel user) async {
    debugPrint('💾 [UserRepository] Saving user profile for UID: ${user.uid} \nData: ${user.toMap()}');
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
      debugPrint('✅ [UserRepository] User profile saved successfully!');
    } catch (e, st) {
      debugPrint('❌ [UserRepository] Error saving user profile: $e\n$st');
      rethrow;
    }
  }

  Future<UserModel?> getUser(String uid) async {
    debugPrint('🔍 [UserRepository] Fetching profile for UID: $uid');
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        debugPrint('✅ [UserRepository] Profile found for UID: $uid');
        return UserModel.fromMap(doc.data()!);
      }
      debugPrint('⚠️ [UserRepository] No profile found for UID: $uid');
      return null;
    } catch (e, st) {
      debugPrint('❌ [UserRepository] Error fetching user profile: $e\n$st');
      rethrow;
    }
  }
}
