import 'package:askence/pages/home_page.dart';
import 'package:askence/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Askence',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.submitButton),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme.copyWith(
            bodyMedium: const TextStyle(
              fontSize: 15,
              color: AppColors.searchBar,
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
