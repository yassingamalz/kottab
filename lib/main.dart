import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kottab/config/app_theme.dart';
import 'package:kottab/screens/main_screen.dart';

void main() {
  runApp(const KottabApp());
}

class KottabApp extends StatelessWidget {
  const KottabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'كتاب',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
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
  }
}