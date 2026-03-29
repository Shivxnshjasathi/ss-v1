import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';

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

  void _routeBasedOnRole(String role) {
    if (role == 'Builder / Agent') {
      context.go('/provider/builder');
    } else if (role == 'Construction Partner') {
      context.go('/provider/construction');
    } else if (role == 'Legal Advisor') {
      context.go('/provider/legal');
    } else if (role == 'Material Vendor') {
      context.go('/provider/marketplace');
    } else {
      context.go('/home');
    }
  }

  Future<void> _navigateToNext() async {
    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 2));
    
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
              _routeBasedOnRole(profile.role ?? '');
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
      backgroundColor: const Color(0xFF1765FE), // Vibrant electric blue from design
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Logo Image / Icon
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.other_houses_outlined, // Similar modern home icon
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SAMPATTI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const Text(
                    'BAZAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            // Loading Section
            Column(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'LOADING EXPERIENCE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 48),
            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                '© 2024 SAMPATTI BAZAR. ALL RIGHTS RESERVED.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
