import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize FCM listeners for foreground, background tap, and token refresh.
  static Future<void> initialize(BuildContext context) async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LoggerService.i('FCM foreground message: ${message.notification?.title}');
      if (context.mounted) {
        _showInAppNotification(context, message);
      }
    });

    // When user taps a notification that opened the app from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      LoggerService.i('FCM notification tapped: ${message.notification?.title}');
      // You can navigate to a specific screen here based on message.data
    });

    // Handle token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      LoggerService.i('FCM Token refreshed: $newToken');
      _syncTokenToFirestore(newToken);
    });

    // Sync initial token
    final token = await getToken();
    if (token != null) {
      _syncTokenToFirestore(token);
    }

    // Subscribe to a topic for broadcast notifications
    await _messaging.subscribeToTopic('all_users');
    LoggerService.i('FCM subscribed to topic: all_users');
  }

  static Future<void> _syncTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        LoggerService.i('FCM Token synced to Firestore for user ${user.uid}');
      } catch (e) {
        // If document doesn't exist or fails, we might need to set it, 
        // but update is safer if the user profile already exists.
        LoggerService.e('FCM: Error syncing token to Firestore', error: e);
      }
    }
  }

  /// Show an in-app banner notification when a message arrives in the foreground
  static void _showInAppNotification(BuildContext context, RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1E60FF),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? 'Sampatti Bazar',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  if (notification.body != null)
                    Text(
                      notification.body!,
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get the current FCM token
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        LoggerService.i('FCM: Successfully retrieved token: ${token.substring(0, 10)}...');
      } else {
        LoggerService.w('FCM: Token is null');
      }
      return token;
    } catch (e, st) {
      LoggerService.e('FCM: Error getting token', error: e, stack: st);
      return null;
    }
  }
}
