import 'package:eitangocho/app/main_page.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// アプリのルートウィジェット。
class EitangochoApp extends StatelessWidget {
  const EitangochoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorSchemeSeed: AppColors.accent,
      ),
      home: const MainPage(),
    );
  }
}
