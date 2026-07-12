import 'package:flutter/material.dart';

// ── Light palette ─────────────────────────────────────────────────────────────
const kPrimary   = Color(0xFF6C63FF);
const kPrimaryDk = Color(0xFF4A42D6);
const kBg        = Color(0xFFF8F9FA);
const kSurface   = Colors.white;
const kBorder    = Color(0xFFE5E7EB);
const kText      = Color(0xFF111111);
const kTextMuted = Color(0xFF6B7280);
const kSuccess   = Color(0xFF10B981);
const kWarning   = Color(0xFFF59E0B);
const kDanger    = Color(0xFFEF4444);

// ── Dark palette ──────────────────────────────────────────────────────────────
const kDarkBg      = Color(0xFF0F0F0F);
const kDarkSurface = Color(0xFF1C1C1E);
const kDarkBorder  = Color(0xFF38383A);
const kDarkText    = Color(0xFFF2F2F7);
const kDarkMuted   = Color(0xFF8E8E93);

// ── Adaptive colour accessor (use inside build methods) ───────────────────────
extension AppColors on BuildContext {
  bool  get isDark    => Theme.of(this).brightness == Brightness.dark;
  Color get cBg       => isDark ? kDarkBg      : kBg;
  Color get cSurface  => isDark ? kDarkSurface : kSurface;
  Color get cBorder   => isDark ? kDarkBorder  : kBorder;
  Color get cText     => isDark ? kDarkText    : kText;
  Color get cMuted    => isDark ? kDarkMuted   : kTextMuted;
}

// ── Shared shape helpers ──────────────────────────────────────────────────────
OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
    OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width));

// ── Light theme ───────────────────────────────────────────────────────────────
ThemeData appTheme() => ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(seedColor: kPrimary, brightness: Brightness.light),
      scaffoldBackgroundColor: kBg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: kSurface,
        foregroundColor: kText,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: kText),
      ),
      cardTheme: CardTheme(
        color: kSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          side: const BorderSide(color: kPrimary),
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        border: _inputBorder(kBorder),
        enabledBorder: _inputBorder(kBorder),
        focusedBorder: _inputBorder(kPrimary, width: 2),
        errorBorder: _inputBorder(kDanger),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: kBg,
        selectedColor: kPrimary.withOpacity(0.12),
        side: const BorderSide(color: kBorder),
        labelStyle: const TextStyle(fontSize: 13, color: kText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme:
          const DividerThemeData(color: kBorder, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

// ── Dark theme ────────────────────────────────────────────────────────────────
ThemeData darkTheme() => ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(seedColor: kPrimary, brightness: Brightness.dark),
      scaffoldBackgroundColor: kDarkBg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: kDarkSurface,
        foregroundColor: kDarkText,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: kDarkText),
      ),
      cardTheme: CardTheme(
        color: kDarkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kDarkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          side: const BorderSide(color: kPrimary),
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kDarkSurface,
        border: _inputBorder(kDarkBorder),
        enabledBorder: _inputBorder(kDarkBorder),
        focusedBorder: _inputBorder(kPrimary, width: 2),
        errorBorder: _inputBorder(kDanger),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: kDarkMuted),
        hintStyle: const TextStyle(color: kDarkMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: kDarkSurface,
        selectedColor: kPrimary.withOpacity(0.20),
        side: const BorderSide(color: kDarkBorder),
        labelStyle: const TextStyle(fontSize: 13, color: kDarkText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(
          color: kDarkBorder, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: kDarkSurface,
        contentTextStyle: const TextStyle(color: kDarkText),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: kDarkSurface,
        selectedItemColor: kPrimary,
        unselectedItemColor: kDarkMuted,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: kDarkSurface,
        indicatorColor: kPrimary.withOpacity(0.20),
      ),
    );
