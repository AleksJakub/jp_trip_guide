import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    const Color vermilionRed = Color(0xFFE60012); // torii red
    const Color indigoBlue = Color(0xFF1A237E);   // ai indigo
    const Color softOffWhite = Color(0xFFFAF8F5); // washi paper
    const Color leafGreen = Color(0xFF2E7D32);

    final ColorScheme base = ColorScheme.fromSeed(seedColor: indigoBlue, brightness: Brightness.light);
    final ColorScheme scheme = base.copyWith(
      primary: indigoBlue,
      secondary: vermilionRed,
      tertiary: leafGreen,
    );
    final TextTheme textTheme = GoogleFonts.notoSansTextTheme()
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
        .copyWith(bodyMedium: const TextStyle(fontSize: 16));
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: softOffWhite,
      textTheme: textTheme,
      iconTheme: const IconThemeData(size: 22),
      appBarTheme: AppBarTheme(backgroundColor: scheme.surface, foregroundColor: scheme.onSurface),
    );
  }

  static ThemeData dark() {
    const Color vermilionRed = Color(0xFFE60012);
    const Color indigoBlue = Color(0xFF1A237E);
    final ColorScheme scheme = ColorScheme.fromSeed(seedColor: indigoBlue, brightness: Brightness.dark).copyWith(secondary: vermilionRed);
    final TextTheme textTheme = GoogleFonts.notoSansTextTheme(ThemeData(brightness: Brightness.dark).textTheme)
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
        .copyWith(bodyMedium: const TextStyle(fontSize: 16));
    return ThemeData(colorScheme: scheme, useMaterial3: true, textTheme: textTheme, iconTheme: const IconThemeData(size: 22));
  }
}


