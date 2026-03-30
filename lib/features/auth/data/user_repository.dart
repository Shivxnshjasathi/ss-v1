import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const String _userCacheKey = 'cached_user_profile';

  UserRepository(this._firestore);

  Future<void> saveUser(UserModel user) async {
    debugPrint('💾 [UserRepository] Saving user profile for UID: ${user.uid}');
    try {
      // Save to Firestore
      await _firestore.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
      
      // Cache locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userCacheKey, jsonEncode(user.toMap()));
      
      debugPrint('✅ [UserRepository] User profile saved and cached successfully!');
    } catch (e, st) {
      debugPrint('❌ [UserRepository] Error saving user profile: $e\n$st');
      rethrow;
    }
  }

  Future<UserModel?> getUser(String uid) async {
    debugPrint('🔍 [UserRepository] Fetching profile for UID: $uid');
    try {
      // Try local cache first if we want extreme speed, but generally we fetch once per session or on splash
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final user = UserModel.fromMap(doc.data()!);
        
        // Update cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userCacheKey, jsonEncode(user.toMap()));
        
        debugPrint('✅ [UserRepository] Profile found and cached for UID: $uid');
        return user;
      }
      debugPrint('⚠️ [UserRepository] No profile found for UID: $uid');
      return null;
    } catch (e, st) {
      debugPrint('❌ [UserRepository] Error fetching user profile: $e\n$st');
      rethrow;
    }
  }

  /// Synchronously get the cached user profile if available
  Future<UserModel?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_userCacheKey);
      if (cachedData != null) {
        return UserModel.fromMap(jsonDecode(cachedData));
      }
    } catch (e) {
      debugPrint('❌ [UserRepository] Error reading cached user: $e');
    }
    return null;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);
  }
}
