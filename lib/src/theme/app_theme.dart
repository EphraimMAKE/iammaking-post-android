import 'package:flutter/material.dart';

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

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: kPrimary, brightness: Brightness.light),
  scaffoldBackgroundColor: kBg,
  fontFamily: 'Roboto',
  appBarTheme: const AppBarTheme(
    backgroundColor: kSurface,
    foregroundColor: kText,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: false,
    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kText),
  ),
  cardTheme: CardThemeData(
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kPrimary,
      side: const BorderSide(color: kPrimary),
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kSurface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kDanger)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kSurface,
    selectedItemColor: kPrimary,
    unselectedItemColor: kTextMuted,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: kBg,
    selectedColor: kPrimary.withOpacity(0.12),
    side: const BorderSide(color: kBorder),
    labelStyle: const TextStyle(fontSize: 13, color: kText),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
);
