import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores principales - Paleta profesional con acento neón
  // Tema Claro - Tonos suaves y profesionales
  static const Color primaryColorLight = Color(0xFF2B4B7C);     // Azul corporativo
  static const Color accentColorLight = Color(0xFF2ce0bd);      // Neón turquesa
  static const Color backgroundColorLight = Color(0xFFF5F7FA);  // Gris muy claro
  static const Color surfaceColorLight = Color(0xFFFFFFFF);     // Blanco puro
  
  // Tema Oscuro - Tonos profundos con neón
  static const Color primaryColorDark = Color(0xFF2ce0bd);      // Neón turquesa
  static const Color accentColorDark = Color(0xFF2B4B7C);       // Azul oscuro
  static const Color backgroundDeep = Color(0xFF0a0a0f);        // Negro profundo
  static const Color backgroundScreenCenter = Color(0xFF1a2332); // Azul oscuro medio
  static const Color backgroundScreenEdge = Color(0xFF0b1016);  // Negro azulado
  
  // Colores compatibilidad
  static const Color primaryColor = primaryColorLight;
  static const Color backgroundColor = backgroundColorLight;
  static const Color surfaceColor = surfaceColorLight;
  static const Color secondaryTextColor = Color(0xFF888888);
  static const Color accentColor = accentColorLight;
  static const Color greenAccent = accentColorLight;

  // Text Theme compartido
  static TextTheme _createTextTheme(ColorScheme colorScheme) {
    final textColor = colorScheme.onSurface;
    
    return TextTheme(
      displayLarge: GoogleFonts.lora(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.lora(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      displaySmall: GoogleFonts.lora(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
    );
  }

  // ColorScheme para Light Mode - Profesional con acentos turquesa
  static ColorScheme lightColorScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF2B4B7C),          // Azul corporativo
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD6E4F5), // Azul muy claro
      onPrimaryContainer: Color(0xFF1A2F4F),
      secondary: Color(0xFF2ce0bd),        // Neón turquesa
      onSecondary: Color(0xFF003A32),
      secondaryContainer: Color(0xFFB8F5E8), // Turquesa muy claro
      onSecondaryContainer: Color(0xFF004D42),
      tertiary: Color(0xFF5C7C99),         // Azul grisáceo
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFDDE7F2),
      onTertiaryContainer: Color(0xFF2A3F54),
      error: Color(0xFFDC3545),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFE5E8),
      onErrorContainer: Color(0xFF8B1A1F),
      surface: Color(0xFFFFFFFF),          // Blanco puro
      onSurface: Color(0xFF1A1C1E),
      onSurfaceVariant: Color(0xFF64788c),
      outline: Color(0xFFB0BEC5),
      outlineVariant: Color(0xFFE0E7ED),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF1a2332),
      inversePrimary: Color(0xFF2ce0bd),
      surfaceTint: Color(0xFF2B4B7C),
    );
  }

  // ColorScheme para Dark Mode - Neón sobre oscuro profundo
  static ColorScheme darkColorScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF2ce0bd),          // Neón turquesa
      onPrimary: Color(0xFF003A32),
      primaryContainer: Color(0xFF1a2332),  // Azul oscuro medio
      onPrimaryContainer: Color(0xFFB8F5E8),
      secondary: Color(0xFF5C8FD7),         // Azul medio brillante
      onSecondary: Color(0xFF0D1F3D),
      secondaryContainer: Color(0xFF2B4B7C), // Azul corporativo oscuro
      onSecondaryContainer: Color(0xFFD6E4F5),
      tertiary: Color(0xFF7C9CB8),          // Azul grisáceo claro
      onTertiary: Color(0xFF1A2F4F),
      tertiaryContainer: Color(0xFF3A5570),
      onTertiaryContainer: Color(0xFFDDE7F2),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF0b1016),           // Negro azulado (bg-screen-edge)
      onSurface: Color(0xFFFFFFFF),         // Blanco puro
      onSurfaceVariant: Color(0xFF888888),  // Gris texto
      outline: Color(0xFF64788c),           // Border inactive
      outlineVariant: Color(0xFF2B3A4A),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFFFFFFF),
      inversePrimary: Color(0xFF2B4B7C),
      surfaceTint: Color(0xFF2ce0bd),
    );
  }

  // Tema Light
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: lightColorScheme(),
    textTheme: _createTextTheme(lightColorScheme()),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Fondo general gris claro
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme().surface,
      foregroundColor: lightColorScheme().onSurface,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: lightColorScheme().onSurface),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: lightColorScheme().onSurface,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightColorScheme().secondary, // Turquesa neón
        foregroundColor: const Color(0xFF003A32), // Texto oscuro sobre turquesa
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: lightColorScheme().outlineVariant,
          width: 1,
        ),
      ),
      color: const Color(0xFFFFFFFF),
      shadowColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFB), // Gris muy muy claro
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: lightColorScheme().outlineVariant, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: lightColorScheme().outlineVariant, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: lightColorScheme().secondary, width: 2), // Turquesa al enfocar
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: lightColorScheme().error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: lightColorScheme().error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );

  // Tema Dark
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: darkColorScheme(),
    textTheme: _createTextTheme(darkColorScheme()),
    scaffoldBackgroundColor: const Color(0xFF0a0a0f), // Fondo general negro profundo
    // Asegurar que el texto en los inputs sea blanco
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFF2ce0bd), // Cursor turquesa
      selectionColor: Color(0xFF2ce0bd), // Selección turquesa
      selectionHandleColor: Color(0xFF2ce0bd),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme().surface,
      foregroundColor: darkColorScheme().onSurface,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkColorScheme().onSurface),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: darkColorScheme().onSurface,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkColorScheme().primary, // Neón turquesa
        foregroundColor: const Color(0xFF0a0a0f), // Texto muy oscuro sobre neón
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: darkColorScheme().outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      color: const Color(0xFF1a2332),  // bg-screen-center
      shadowColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1a2332),  // bg-screen-center
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: darkColorScheme().outline, width: 1.5), // border-inactive
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: darkColorScheme().outline, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: darkColorScheme().primary, width: 2), // Neón turquesa
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: darkColorScheme().error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: darkColorScheme().error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF888888)), // text-grey
      labelStyle: const TextStyle(color: Color(0xFFFFFFFF)), // Blanco para labels
      floatingLabelStyle: TextStyle(color: darkColorScheme().primary), // Neón turquesa
      prefixIconColor: const Color(0xFF888888),
      suffixIconColor: const Color(0xFF888888),
    ),
  );
}