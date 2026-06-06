import 'package:flutter/material.dart';

/// Tema visual de CrediDriveP.
///
/// Paleta corporativa azul/verde, tipografía Inter, esquinas suaves y
/// elevaciones bajas. Pensado para que la app financiera transmita
/// confianza y precisión.
class AppTheme {
  static const Color brandPrimary = Color(0xFF0B5FFF);   // Azul CrediDrive
  static const Color brandPrimaryDark = Color(0xFF0846B8);
  static const Color brandAccent = Color(0xFF12B886);    // Verde calculadora
  static const Color brandWarning = Color(0xFFFFA94D);
  static const Color brandDanger = Color(0xFFE03131);
  static const Color surface = Color(0xFFF5F7FB);
  static const Color surfaceCard = Colors.white;
  static const Color textPrimary = Color(0xFF1A2236);
  static const Color textSecondary = Color(0xFF5A6677);

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: brandPrimary,
      brightness: Brightness.light,
      primary: brandPrimary,
      secondary: brandAccent,
      surface: surfaceCard,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: surface,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
        titleLarge: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        titleMedium: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 15, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
        bodySmall: TextStyle(fontSize: 12, color: textSecondary),
        labelLarge: TextStyle(fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: brandPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceCard,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: const TextStyle(color: textSecondary),
        floatingLabelStyle: const TextStyle(color: brandPrimary, fontWeight: FontWeight.w600),
        helperStyle: const TextStyle(color: textSecondary, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandPrimary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandDanger, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandPrimary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: brandPrimary, width: 1.4),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brandAccent,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: brandPrimary.withOpacity(0.08),
        side: BorderSide(color: brandPrimary.withOpacity(0.2)),
        labelStyle: const TextStyle(
            color: brandPrimaryDark, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E6EE),
        thickness: 1,
        space: 1,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(brandPrimary.withOpacity(0.06)),
        headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w700, color: textPrimary, fontSize: 13),
        dataTextStyle: const TextStyle(fontSize: 13, color: textPrimary),
        dividerThickness: 0.5,
      ),
    );
  }
}
