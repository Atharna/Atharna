import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData _build(Brightness b) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7C86), brightness: b),
        cardTheme: CardTheme(elevation: 0, clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
      );
  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);
}

/// Breakpoints: <600 phone, <900 tablet, >=900 desktop
class Responsive {
  static bool isDesktop(BuildContext c) => MediaQuery.sizeOf(c).width >= 900;
  static Widget center(Widget child) =>
      Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1200), child: child));
}
