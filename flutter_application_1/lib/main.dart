import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'frame1.dart';

void main() {
  runApp(const FigmaToCodeApp()); // Only one main() in your app
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.light, // Default to light since most frames are light
      home: const Frame1(), // Directly use Frame1 as home screen
      // Optional: Removes debug banner
    );
  }
}