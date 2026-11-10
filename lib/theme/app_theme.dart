import 'package:flutter/material.dart';

/// AppTheme mengelola seluruh token desain visual aplikasi:
/// warna, tipografi, radius sudut, dan jarak (spacing kelipatan 8).
///
/// Nilai-nilai token diselaraskan dengan referensi Google Stitch
/// ("Indonesian Editorial News UI" / NewsScope di folder stitch_design/).
class AppTheme {
  // Private constructor agar class ini tidak dapat diinstansiasi langsung.
  AppTheme._();

  // ==========================================
  // PALET WARNA (Design Tokens)
  // ==========================================

  // Warna Utama (Editorial Deep Black / Charcoal)
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF0E1D2A);
  static const Color onPrimaryContainer = Color(0xFF778596);

  // Warna Sekunder / Aksen Editorial (Red Carmine)
  static const Color secondary = Color(0xFFBB0413);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDF2A29);
  static const Color onSecondaryContainer = Color(0xFFFFFBFF);

  // Warna Netral & Latar (Surface & Background)
  static const Color background = Color(0xFFF8F9FA);
  static const Color onBackground = Color(0xFF191C1D);

  static const Color surface = Color(0xFFF8F9FA);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color surfaceVariant = Color(0xFFE1E3E4);
  static const Color onSurfaceVariant = Color(0xFF44474C);

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);

  // Garis Tepi & Pemisah (Borders / Outlines)
  static const Color outline = Color(0xFF74777C);
  static const Color outlineVariant = Color(0xFFC4C6CC);

  // Status & Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ==========================================
  // SPACING BERBASIS KELIPATAN 8 (dan 4 untuk mikro)
  // ==========================================
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double space2Xl = 48.0;

  // Margin standar halaman (gutter)
  static const double gutter = 16.0;

  // ==========================================
  // RADIUS SUDUT (Border Radius)
  // ==========================================
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 999.0;

  // ==========================================
  // TIPOGRAFI
  // ==========================================
  // Gaya font serif untuk judul berita (editorial) dan sans-serif untuk isi/label
  static const TextStyle headlineLg = TextStyle(
    fontSize: 28.0,
    height: 36.0 / 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: onSurface,
  );

  static const TextStyle headlineMd = TextStyle(
    fontSize: 20.0,
    height: 26.0 / 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: onSurface,
  );

  static const TextStyle headlineSm = TextStyle(
    fontSize: 17.0,
    height: 22.0 / 17.0,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: 18.0,
    height: 28.0 / 18.0,
    fontWeight: FontWeight.w400,
    color: onSurface,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: 16.0,
    height: 24.0 / 16.0,
    fontWeight: FontWeight.w400,
    color: onSurface,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: FontWeight.w400,
    color: onSurfaceVariant,
  );

  static const TextStyle labelLg = TextStyle(
    fontSize: 13.0,
    height: 16.0 / 13.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: onSurface,
  );

  static const TextStyle labelMd = TextStyle(
    fontSize: 11.0,
    height: 14.0 / 11.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: onSurfaceVariant,
  );

  static const TextStyle labelSm = TextStyle(
    fontSize: 10.0,
    height: 12.0 / 10.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: onSurfaceVariant,
  );

  // ==========================================
  // THEMEDATA LENGKAP (Material 3)
  // ==========================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceContainerHighest,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: headlineSm,
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: outlineVariant, width: 0.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainer,
        selectedColor: primary,
        disabledColor: surfaceVariant,
        labelStyle: labelMd,
        secondaryLabelStyle: labelMd.copyWith(color: onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMd,
          vertical: 10.0,
        ),
        hintStyle: bodySm.copyWith(color: outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: outlineVariant,
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}

