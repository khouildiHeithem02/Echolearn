import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EchoLearnTheme {
  // Pediatric-friendly palette (inclusive for boys and girls)
  static const Color primaryBlue = Color(0xFF64B5F6); // Soft sky blue
  static const Color accentYellow = Color(0xFFFFD54F); // Warm sunshine yellow
  static const Color softCoral = Color(0xFFFF8A65); // Gentle coral pink
  static const Color bgCream = Color(0xFFFFFDE7); // Very soft cream
  static const Color primaryNavy = Color(0xFF283593); // For text and structure
  
  static const Color successGreen = Color(0xFF81C784);
  static const Color errorRed = Color(0xFFFF8A80);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentYellow,
        tertiary: softCoral,
      ),
      scaffoldBackgroundColor: bgCream,
      textTheme: GoogleFonts.cairoTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: primaryNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: primaryNavy,
        ),
        iconTheme: const IconThemeData(color: primaryNavy),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          elevation: 4,
          shadowColor: primaryBlue.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        color: Colors.white,
      ),
    );
  }
}
