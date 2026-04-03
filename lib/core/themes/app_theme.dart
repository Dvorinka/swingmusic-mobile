import 'package:flutter/material.dart';

class AppTheme {
  // Web client palette tokens
  static const Color highlightBlue = Color(0xFF006EFF);
  static const Color darkestBlue = Color(0xFF234ECE);
  static const Color darkBlue = Color(0xFF055EE2);

  static const Color body = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFDE);
  static const Color gray = Color(0xFF1A1919);
  static const Color gray1 = Color(0xFF8E8E93);
  static const Color gray2 = Color(0xFF636366);
  static const Color gray3 = Color(0xFF48484A);
  static const Color gray4 = Color(0xFF3A3A3C);
  static const Color gray5 = Color(0xFF2C2C2E);

  static const Color red = Color(0xFFF7635C);
  static const Color green = Color(0xFF5EF784);
  static const Color orange = Color(0xFFFF9F0A);
  static const Color onPrimaryColor = Colors.white;

  static const Color _divider = Color(0xFF3A3A3C);

  static const ColorScheme _darkScheme = ColorScheme.dark(
    primary: highlightBlue,
    secondary: darkBlue,
    tertiary: green,
    surface: body,
    surfaceContainerHighest: gray5,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.black,
    onSurface: white,
    onSurfaceVariant: gray1,
    outline: gray3,
    outlineVariant: _divider,
    error: red,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'SF Compact Display',
    colorScheme: _darkScheme,
    scaffoldBackgroundColor: body,
    canvasColor: body,
    splashColor: darkestBlue.withOpacity(0.15),
    highlightColor: darkestBlue.withOpacity(0.12),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: body,
      foregroundColor: white,
      titleTextStyle: TextStyle(
        fontFamily: 'SF Compact Display',
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: white,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: _divider,
      thickness: 1,
      space: 24,
    ),
    // Cast via dynamic so this remains compatible across Flutter versions
    // where ThemeData expects CardTheme or CardThemeData.
    cardTheme: CardTheme(
      elevation: 0,
      color: gray5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    ) as dynamic,
    listTileTheme: ListTileThemeData(
      textColor: white,
      iconColor: gray1,
      tileColor: gray5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gray5,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: gray4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: gray4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: highlightBlue, width: 1.3),
      ),
      hintStyle: const TextStyle(color: gray1),
      labelStyle: const TextStyle(color: gray1),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: gray4,
      surfaceTintColor: Colors.transparent,
      indicatorColor: darkestBlue,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? Colors.white : gray1);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? Colors.white : gray1,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        );
      }),
    ),
    // Cast via dynamic so this remains compatible across Flutter versions
    // where ThemeData expects TabBarTheme or TabBarThemeData.
    tabBarTheme: TabBarTheme(
      indicatorColor: highlightBlue,
      dividerColor: _divider,
      labelColor: white,
      unselectedLabelColor: gray1,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
    ) as dynamic,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: highlightBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'SF Compact Display',
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: highlightBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: white,
        side: const BorderSide(color: gray3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: white),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: highlightBlue,
      linearTrackColor: gray4,
      circularTrackColor: gray4,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: highlightBlue,
      inactiveTrackColor: gray4,
      thumbColor: white,
      overlayColor: Color(0x33006EFF),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: white,
        fontWeight: FontWeight.w700,
        fontSize: 34,
      ),
      headlineMedium: TextStyle(
        color: white,
        fontWeight: FontWeight.w700,
        fontSize: 28,
      ),
      headlineSmall: TextStyle(
        color: white,
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
      titleLarge: TextStyle(
        color: white,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleMedium: TextStyle(
        color: white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: TextStyle(color: white, fontSize: 16, height: 1.35),
      bodyMedium: TextStyle(color: white, fontSize: 14, height: 1.35),
      bodySmall: TextStyle(color: gray1, fontSize: 12, height: 1.35),
      labelLarge: TextStyle(color: white, fontWeight: FontWeight.w700),
      labelMedium: TextStyle(color: gray1, fontSize: 12),
    ),
  );

  // Keep a light theme for compatibility, but still aligned to SwingMusic palette.
  static final ThemeData lightTheme = darkTheme.copyWith(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: highlightBlue,
      secondary: darkBlue,
      tertiary: green,
      surface: Color(0xFFF8F8F8),
      surfaceContainerHighest: Color(0xFFEDEDED),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: Color(0xFF1A1919),
      onSurfaceVariant: Color(0xFF636366),
      outline: Color(0xFFD7D7D8),
      outlineVariant: Color(0xFFE4E4E5),
      error: red,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F8F8),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Color(0xFFF8F8F8),
      foregroundColor: Color(0xFF1A1919),
      titleTextStyle: TextStyle(
        fontFamily: 'SF Compact Display',
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: Color(0xFF1A1919),
      ),
    ),
  );
}
