import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/features/auth/presentation/screens/login_screen.dart';
import 'package:sampatti_bazar/features/auth/presentation/screens/otp_screen.dart';
import 'package:sampatti_bazar/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:sampatti_bazar/features/chatbot/presentation/screens/chatbot_screen.dart';
import 'package:sampatti_bazar/features/home/presentation/screens/home_screen.dart';
import 'package:sampatti_bazar/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:sampatti_bazar/features/properties/presentation/screens/property_feed_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/construction_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/home_loan_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/legal_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/materials_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/movers_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phoneNumber = state.extra as String? ?? '';
        return OtpScreen(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/chatbot',
      builder: (context, state) => const ChatbotScreen(),
    ),
    GoRoute(
      path: '/properties',
      builder: (context, state) => const PropertyFeedScreen(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) {
             final id = state.pathParameters['id'] ?? '';
             return PropertyDetailScreen(propertyId: id);
          },
        ),
      ]
    ),
    GoRoute(
      path: '/services/loan',
      builder: (context, state) => const HomeLoanScreen(),
    ),
    GoRoute(
      path: '/services/movers',
      builder: (context, state) => const MoversScreen(),
    ),
    GoRoute(
      path: '/services/construction',
      builder: (context, state) => const ConstructionScreen(),
    ),
    GoRoute(
      path: '/services/materials',
      builder: (context, state) => const MaterialsScreen(),
    ),
    GoRoute(
      path: '/services/legal',
      builder: (context, state) => const LegalScreen(),
    ),
  ],
);
