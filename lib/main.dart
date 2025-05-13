import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kottab/config/app_theme.dart';
import 'package:kottab/providers/quran_provider.dart';
import 'package:kottab/providers/statistics_provider.dart';
import 'package:kottab/providers/schedule_provider.dart';
import 'package:kottab/providers/session_provider.dart';
import 'package:kottab/providers/settings_provider.dart';
import 'package:kottab/screens/main_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const KottabApp(),
    ),
  );
}

class KottabApp extends StatelessWidget {
  const KottabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'كتاب',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme, // We need to implement this
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
          home: const MainScreen(),
        );
      },
    );
  }
}