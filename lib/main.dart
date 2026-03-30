import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/router/app_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/providers/locale_provider.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      debugPrint('Firebase initialized successfully: ${Firebase.app().name}');

      // Initialize Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      
      // Ensure analytics is enabled
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

      runApp(const ProviderScope(child: SampattiBazarApp()));
    },
    (error, stack) {
      // Catch errors outside the framework
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      debugPrint('Uncaught Error: $error');
    },
  );
}

class SampattiBazarApp extends ConsumerWidget {
  const SampattiBazarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize Responsive utility
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            Responsive().init(context);
            return MaterialApp.router(
              title: 'Sampatti Bazar',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeProvider),
      locale: ref.watch(localeProvider),
      routerConfig: goRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
      ],
      debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}
