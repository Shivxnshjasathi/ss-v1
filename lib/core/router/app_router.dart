import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sampatti_bazar/core/router/main_layout_screen.dart';
import 'package:sampatti_bazar/features/splash/presentation/screens/splash_screen.dart';
import 'package:sampatti_bazar/features/auth/presentation/screens/login_screen.dart';
import 'package:sampatti_bazar/features/auth/presentation/screens/otp_screen.dart';
import 'package:sampatti_bazar/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:sampatti_bazar/features/chatbot/presentation/screens/chatbot_screen.dart';
import 'package:sampatti_bazar/features/home/presentation/screens/home_screen.dart';
import 'package:sampatti_bazar/features/properties/presentation/screens/add_property_screen.dart';
import 'package:sampatti_bazar/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:sampatti_bazar/features/properties/presentation/screens/property_feed_screen.dart';
import 'package:sampatti_bazar/features/properties/presentation/screens/saved_properties_screen.dart';
import 'package:sampatti_bazar/features/properties/presentation/screens/media_viewer_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/construction_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/home_loan_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/legal_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/rent_agreement_sign_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/marketplace_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/cart_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/checkout_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/movers_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/services_hub_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/other_services_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/service_tracking_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/insurance_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/maintenance_service_screen.dart';
import 'package:sampatti_bazar/features/profile/presentation/screens/profile_screen.dart';
import 'package:sampatti_bazar/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:sampatti_bazar/features/profile/presentation/screens/documents_screen.dart';
import 'package:sampatti_bazar/features/profile/presentation/screens/settings_screen.dart';
import 'package:sampatti_bazar/features/profile/presentation/screens/support_screen.dart';
import 'package:sampatti_bazar/features/auth/presentation/screens/notification_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/providers/construction_dashboard_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/providers/legal_dashboard_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/providers/marketplace_vendor_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/providers/builder_agent_dashboard_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/providers/finance_dashboard_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/providers/movers_dashboard_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/providers/handyman_dashboard_screen.dart';
import 'package:sampatti_bazar/features/financial/presentation/screens/financial_center_screen.dart';
import 'package:sampatti_bazar/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:sampatti_bazar/features/chat/presentation/screens/chat_detail_screen.dart';
import 'package:sampatti_bazar/features/services/presentation/screens/offers_screen.dart';
import 'package:sampatti_bazar/features/properties/presentation/screens/property_management_screen.dart';
import 'package:sampatti_bazar/features/properties/presentation/screens/my_properties_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  observers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final phoneNumber = extra['phoneNumber'] as String? ?? '';
        final verificationId = extra['verificationId'] as String? ?? '';
        return OtpScreen(phoneNumber: phoneNumber, verificationId: verificationId);
      },
    ),

    GoRoute(
      path: '/chatbot',
      builder: (context, state) => const ChatbotScreen(),
    ),
    GoRoute(
      path: '/add-property',
      builder: (context, state) => const AddPropertyScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayoutScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/services',
              builder: (context, state) => const ServicesHubScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/services/tracking',
              builder: (context, state) => const ServiceTrackingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chats',
              builder: (context, state) => const ChatListScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: 'documents',
          builder: (context, state) => const DocumentsScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const AppSettingsScreen(),
        ),
        GoRoute(
          path: 'support',
          builder: (context, state) => const HelpSupportScreen(),
        ),
      ],
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
        GoRoute(
          path: 'my',
          builder: (context, state) => const MyPropertiesScreen(),
        ),
        GoRoute(
          path: 'manage/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return PropertyManagementScreen(propertyId: id);
          },
        ),
        GoRoute(
          path: 'media',
          builder: (context, state) {
            final url = state.uri.queryParameters['url'] ?? '';
            final type = state.uri.queryParameters['type'] ?? 'video';
            return MediaViewerScreen(url: url, mediaType: type);
          },
        ),
      ]
    ),
    GoRoute(
      path: '/services/loan',
      builder: (context, state) => const HomeLoanScreen(),
    ),
    GoRoute(
      path: '/services/insurance',
      builder: (context, state) => const InsuranceScreen(),
    ),
    GoRoute(
      path: '/services/maintenance',
      builder: (context, state) => const MaintenanceServiceScreen(),
    ),
    GoRoute(
      path: '/services/emi-calculator',
      builder: (context, state) => const FinancialCenterScreen(),
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
      path: '/services/marketplace',
      builder: (context, state) => const MarketplaceScreen(),
      routes: [
        GoRoute(
          path: 'cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: 'checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
      ]
    ),
    GoRoute(
      path: '/services/legal',
      builder: (context, state) => const LegalScreen(),
      routes: [
        GoRoute(
          path: 'sign/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return RentAgreementSignScreen(agreementId: id);
          },
        ),
      ]
    ),
    GoRoute(
      path: '/services/other',
      builder: (context, state) => const OtherServicesScreen(),
    ),
    GoRoute(
      path: '/services/tracking',
      builder: (context, state) => const ServiceTrackingScreen(),
    ),
    GoRoute(
      path: '/services/offers',
      builder: (context, state) => const OffersScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: '/saved',
      builder: (context, state) => const SavedPropertiesScreen(),
    ),
    GoRoute(
      path: '/provider/construction',
      builder: (context, state) => const ConstructionDashboardScreen(),
    ),
    GoRoute(
      path: '/provider/legal',
      builder: (context, state) => const LegalDashboardScreen(),
    ),
    GoRoute(
      path: '/provider/marketplace',
      builder: (context, state) => const MarketplaceVendorScreen(),
    ),
    GoRoute(
      path: '/provider/builder',
      builder: (context, state) => const BuilderAgentDashboardScreen(),
    ),
    GoRoute(
      path: '/provider/finance',
      builder: (context, state) => const FinanceDashboardScreen(),
    ),
    GoRoute(
      path: '/provider/movers',
      builder: (context, state) => const MoversDashboardScreen(),
    ),
    GoRoute(
      path: '/provider/handyman',
      builder: (context, state) => const HandymanDashboardScreen(),
    ),
    GoRoute(
      path: '/chats/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ChatDetailScreen(chatId: id);
      },
    ),
  ],
);
