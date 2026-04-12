import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/core/utils/routing_utils.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Try to get cached user for instant redirect
    final cachedUser = await ref.read(userRepositoryProvider).getCachedUser();
    
    if (mounted && cachedUser != null) {
      debugPrint('⚡ [SplashScreen] Found cached user: ${cachedUser.uid}, Redirecting immediately.');
      RoutingUtils.navigateByRole(context, cachedUser.role);
      return;
    }

    // Wait for minimum splash duration if no cache (first time or force fetch)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        context.go('/login');
      } else {
        try {
          final profile = await ref.read(userRepositoryProvider).getUser(user.uid);
          if (mounted) {
            if (profile == null) {
              context.go('/onboarding');
            } else {
              RoutingUtils.navigateByRole(context, profile.role);
            }
          }
        } catch (e) {
          if (mounted) context.go('/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Logo Image / Icon
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/app_logo.png',
                    width: 120.w,
                    height: 120.w,
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCirc),
                  SizedBox(height: 24.h),
                  Text(
                    'SAMPATTI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  Text(
                    'BAZAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
            const Spacer(flex: 2),
            // Loading Section
            Column(
              children: [
                SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'LOADING EXPERIENCE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: 40.w,
                  height: 1.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 800.ms),
            SizedBox(height: 48.h),
            // Footer
            Padding(
              padding: EdgeInsets.only(bottom: 16.0.h),
              child: Text(
                '© 2024 SAMPATTI BAZAR. ALL RIGHTS RESERVED.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ).animate().fadeIn(delay: 1.seconds),
          ],
        ),
      ),
    );
  }
}
