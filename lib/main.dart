import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/router/app_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      debugPrint('Firebase initialized successfully: ${Firebase.app().name}');

      // Pass all uncaught "fatal" errors from the framework to Crashlytics
      // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      // PlatformDispatcher.instance.onError = (error, stack) {
      //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      //   return true;
      // };

      runApp(const ProviderScope(child: SampattiBazarApp()));
    },
    (error, stack) {
      // Catch errors outside the framework
      // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      debugPrint('Uncaught Error: $error');
    },
  );
}

class SampattiBazarApp extends ConsumerWidget {
  const SampattiBazarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Sampatti Bazar',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeProvider),
      routerConfig: goRouter,
      localizationsDelegates: const [
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
  }
}
