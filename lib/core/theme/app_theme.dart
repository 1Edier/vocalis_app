import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE5A14F);
  static const Color backgroundColor = Color(0xFFF6F3ED);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color accentColor = Color(0xFF86A5A8);
  static const Color greenAccent = Color(0xFF90C2AF);

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: greenAccent,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, background: backgroundColor),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black87),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontFamily: 'Lora',
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.black87,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        color: secondaryTextColor,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}