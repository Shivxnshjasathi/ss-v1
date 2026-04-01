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

  Future<void> updatePreApprovalStatus(String uid, bool isPreApproved, double amount, int cibil) async {
    debugPrint('🏦 [UserRepository] Updating pre-approval for UID: $uid');
    try {
      await _firestore.collection('users').doc(uid).update({
        'isPreApproved': isPreApproved,
        'preApprovalAmount': amount,
        'cibilScore': cibil,
      });

      // Clear local cache to force refresh
      await clearCache();
      debugPrint('✅ [UserRepository] Pre-approval updated successfully');
    } catch (e, st) {
      debugPrint('❌ [UserRepository] Error updating pre-approval: $e\n$st');
      rethrow;
    }
  }

  Future<void> updateUserRating(String uid, double newRating) async {
    debugPrint('⭐ [UserRepository] Updating rating for UID: $uid');
    try {
      final docRef = _firestore.collection('users').doc(uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) throw Exception("User doesn't exist");
        
        final currentCount = (snapshot.data()?['ratingCount'] as int?) ?? 0;
        final currentScore = (snapshot.data()?['trustScore'] as num?)?.toDouble() ?? 0.0;
        final currentDeals = (snapshot.data()?['totalDeals'] as int?) ?? 0;

        final newCount = currentCount + 1;
        final newScore = ((currentScore * currentCount) + newRating) / newCount;
        
        // Let's increment deals slightly per rating functionally to simulate activity
        final newDeals = currentDeals == 0 ? 1 : currentDeals;

        transaction.update(docRef, {
          'ratingCount': newCount,
          'trustScore': newScore,
          'totalDeals': newDeals,
        });
      });

      // Clear local cache
      await clearCache();
      debugPrint('✅ [UserRepository] Rating updated successfully');
    } catch (e, st) {
      debugPrint('❌ [UserRepository] Error updating rating: $e\n$st');
      rethrow;
    }
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    debugPrint('🔍 [UserRepository] Searching for user by email: $email');
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final user = UserModel.fromMap(query.docs.first.data());
        debugPrint('✅ [UserRepository] User found with email: $email');
        return user;
      }
      debugPrint('⚠️ [UserRepository] No user found with email: $email');
      return null;
    } catch (e, st) {
      debugPrint('❌ [UserRepository] Error searching for user by email: $e\n$st');
      return null;
    }
  }
}
