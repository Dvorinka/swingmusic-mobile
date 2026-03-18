import 'package:flutter/material.dart';

class AppTheme {
  // Unified color scheme matching web client exactly
  static const Color primaryColor = Color(0xFF006EFF); // $highlight-blue
  static const Color secondaryColor = Color(0xFF8B5CF6); // --color-secondary
  static const Color tertiaryColor = Color(0xFF10B981); // --color-accent
  
  // Web client exact colors
  static const Color highlightBlue = Color(0xFF006EFF); // $highlight-blue
  static const Color darkestBlue = Color(0xFF234ECE); // $darkestblue
  static const Color darkBlue = Color(0xFF055EE2); // $darkblue
  
  // Apple human design guideline colors (exact match)
  static const Color black = Color(0xFF181A1C); // $black
  static const Color white = Color(0xFFFFFFDE); // $white (with alpha)
  static const Color gray = Color(0xFF1A1919); // $gray
  static const Color gray1 = Color(0xFF8E8E93); // $gray1
  static const Color gray2 = Color(0xFF636366); // $gray2
  static const Color gray3 = Color(0xFF48484A); // $gray3
  static const Color gray4 = Color(0xFF3A3A3C); // $gray4
  static const Color gray5 = Color(0xFF2C2C2E); // $gray5
  static const Color body = Color(0xFF000000); // $body
  
  // Semantic colors (exact match)
  static const Color red = Color(0xFFF7635C); // $red
  static const Color blue = Color(0xFF0A84FF); // $blue
  static const Color green = Color(0xFF5EF784); // $green
  static const Color yellow = Color(0xFFFFD60A); // $yellow
  static const Color orange = Color(0xFFFF9F0A); // $orange
  static const Color pink = Color(0xFFFF375F); // $pink
  static const Color purple = Color(0xFFBF5AF2); // $purple
  static const Color brown = Color(0xFFAC8E68); // $brown
  static const Color indigo = Color(0xFF5E5CE6); // $indigo
  static const Color teal = Color(0xFF40C8E0); // $teal
  static const Color lightBrown = Color(0xFFEBCA89); // $lightbrown
  
  static const Color surfaceColor = Color(0xFFFAFAFA); // --color-surface
  static const Color surfaceVariantColor = Color(0xFFF5F5F5); // --color-surface-variant
  static const Color backgroundColor = Color(0xFFFFFFFF); // --color-background
  
  static const Color onPrimaryColor = Color(0xFFFFFFFF); // --color-on-primary
  static const Color onSecondaryColor = Color(0xFFFFFFFF); // --color-on-secondary
  static const Color onTertiaryColor = Color(0xFFFFFFFF); // --color-on-accent
  static const Color onSurfaceColor = Color(0xFF1C1C1C); // --color-on-surface
  static const Color onBackgroundColor = Color(0xFF1C1C1C); // --color-on-background
  
  static const Color outlineColor = Color(0xFFE5E7EB); // --color-border
  static const Color outlineVariantColor = Color(0xFFF3F4F6); // --color-divider
  
  // Status colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // Exact font family matching web client with fallbacks
    fontFamily: 'SF Compact Display',
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: surfaceColor,
      surfaceVariant: surfaceVariantColor,
      background: backgroundColor,
      onPrimary: onPrimaryColor,
      onSecondary: onSecondaryColor,
      onTertiary: onTertiaryColor,
      onSurface: onSurfaceColor,
      onBackground: onBackgroundColor,
      outline: outlineColor,
      outlineVariant: outlineVariantColor,
    ),
    // Consistent transitions matching web client
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: onSurfaceColor,
    ),
    cardTheme: CardThemeData(
      elevation: 0, // Match web client flat design
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Match web client rounded-sm ($small)
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Consistent padding
        elevation: 0, // Match web client flat design
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        textStyle: const TextStyle(
          fontFamily: 'SF Compact Display',
          fontWeight: FontWeight.w700, // Match web client font-weight
          fontSize: 14, // Match web client font-size (0.9rem)
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36, // Match web client larger headings
        fontWeight: FontWeight.w700, // Match web client font-weight
        letterSpacing: 0,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700, // Match web client font-weight
        letterSpacing: 0,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700, // Match web client font-weight
        letterSpacing: 0,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        fontSize: 20, // Match web client title size
        fontWeight: FontWeight.w700, // Match web client font-weight
        letterSpacing: 0,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500, // Match web client font-weight
        letterSpacing: 0.15,
        height: 1.3,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700, // Match web client font-weight
        letterSpacing: 0.1,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400, // Match web client font-weight
        letterSpacing: 0.5,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400, // Match web client font-weight
        letterSpacing: 0.25,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400, // Match web client font-weight
        letterSpacing: 0.4,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700, // Match web client font-weight
        letterSpacing: 0.1,
        height: 1.2,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700, // Match web client font-weight
        letterSpacing: 0.5,
        height: 1.2,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700, // Match web client font-weight
        letterSpacing: 0.5,
        height: 1.2,
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    // Exact font family matching web client with fallbacks
    fontFamily: 'SF Compact Display',
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4A90E2), // Lighter version of $highlight-blue for dark mode
      secondary: Color(0xFFA78BFA), // Lighter secondary for dark mode
      tertiary: Color(0xFF34D399), // Lighter accent for dark mode
      surface: gray4, // Match web client $gray4 exactly
      surfaceVariant: gray5, // Match web client $gray5 exactly
      background: body, // Match web client $body exactly
      onPrimary: Color(0xFF1C1C1C), // Dark text on light primary
      onSecondary: Color(0xFF1C1C1C), // Dark text on light secondary
      onTertiary: Color(0xFF1C1C1C), // Dark text on light accent
      onSurface: white, // Match web client $white
      onBackground: white, // Match web client $white
      outline: gray3, // Match web client $gray4 
      outlineVariant: gray4, // Match web client $gray5
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: white,
    ),
    cardTheme: CardThemeData(
      elevation: 0, // Match web client flat design
      color: gray4, // Match web client card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Match web client rounded-sm ($small)
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Consistent padding
        elevation: 0, // Match web client flat design
        backgroundColor: const Color(0xFF4A90E2), // Updated primary color for dark mode
        foregroundColor: const Color(0xFF1C1C1C), // Dark text on light primary
        textStyle: const TextStyle(
          fontFamily: 'SF Compact Display',
          fontWeight: FontWeight.w700, // Match web client font-weight
          fontSize: 14, // Match web client font-size (0.9rem)
        ),
      ),
    ),
  );
}
