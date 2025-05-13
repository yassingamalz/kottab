import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kottab/config/app_theme.dart';
import 'package:kottab/config/launch/app_initializer.dart';
import 'package:kottab/config/launch/error_handler.dart';
import 'package:kottab/providers/quran_provider.dart';
import 'package:kottab/providers/statistics_provider.dart';
import 'package:kottab/providers/schedule_provider.dart';
import 'package:kottab/providers/session_provider.dart';
import 'package:kottab/providers/settings_provider.dart';
import 'package:kottab/providers/search_provider.dart';
import 'package:kottab/screens/main_screen.dart';
import 'package:kottab/screens/onboarding_screen.dart';
import 'package:kottab/utils/performance/app_performance.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling
  ErrorHandler.instance.init();

  // Initialize the app
  await AppInitializer.instance.initializeApp();

  // Run the app with error zones
  runApp(const KottabApp());

  // Run post-initialization tasks
  AppInitializer.instance.runPostInitTasks();
}

class KottabApp extends StatelessWidget {
  const KottabApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Measure build time
    AppPerformance.instance.startMeasure('app_build');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          // End build time measurement
          AppPerformance.instance.endMeasure('app_build');

          return MaterialApp(
            title: 'كتّاب',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            locale: const Locale('ar', 'SA'),
            supportedLocales: const [
              Locale('ar', 'SA'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Use either onboarding or main screen based on first run status
            home: AppInitializer.instance.isFirstRun
                ? const OnboardingScreen()
                : const MainScreen(),
            builder: (context, child) {
              // Apply global error handling for widgets
              ErrorWidget.builder = (FlutterErrorDetails details) {
                return ErrorHandler.instance.buildErrorWidget(
                  details.exception,
                  details.stack ?? StackTrace.current,
                );
              };

              // Apply any global modifications to the widget tree
              return MediaQuery(
                // Prevent system text scaling from breaking our layout
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}