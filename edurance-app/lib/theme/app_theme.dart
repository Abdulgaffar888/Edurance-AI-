import 'package:flutter/material.dart';

class AppTheme {
  // Aurora inspired color palette
  static const Color _darkBackground = Color(0xFF0A0E1A);
  static const Color _cardBackground = Color(0xFF151929);
  static const Color _surfaceColor = Color(0xFF1E2336);

  // Aurora colors
  static const Color _auroraGreen = Color(0xFF00FF88);
  static const Color _auroraBlue = Color(0xFF00D4FF);
  static const Color _auroraPurple = Color(0xFFB866FF);
  static const Color _auroraPink = Color(0xFFFF6B9D);

  // Text colors
  static const Color _primaryText = Color(0xFFE8EAED);
  static const Color _secondaryText = Color(0xFF9AA0A6);
  static const Color _accentText = Color(0xFF00FF88);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: _auroraGreen,
        secondary: _auroraBlue,
        tertiary: _auroraPurple,
        surface: _surfaceColor,
        background: _darkBackground,
        error: _auroraPink,
        onPrimary: _darkBackground,
        onSecondary: _darkBackground,
        onTertiary: _darkBackground,
        onSurface: _primaryText,
        onBackground: _primaryText,
        onError: _darkBackground,
      ),

      // Scaffold background
      scaffoldBackgroundColor: _darkBackground,

      // Card theme
      cardTheme: const CardThemeData(
        color: _cardBackground,
        elevation: 8,
        shadowColor: _auroraBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceColor,
        foregroundColor: _primaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _auroraGreen,
          foregroundColor: _darkBackground,
          elevation: 4,
          shadowColor: _auroraGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _auroraBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _auroraPurple,
          side: const BorderSide(color: _auroraPurple, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _secondaryText.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _secondaryText.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _auroraGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _auroraPink, width: 2),
        ),
        labelStyle: const TextStyle(color: _secondaryText),
        hintStyle: const TextStyle(color: _secondaryText),
        prefixIconColor: _secondaryText,
        suffixIconColor: _secondaryText,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: _primaryText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: _primaryText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: _primaryText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: _primaryText,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: _primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: _primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: _primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: _primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: _primaryText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: _primaryText,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: _primaryText,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: _secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: _primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: _primaryText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: _secondaryText,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: _primaryText,
        size: 24,
      ),

      // List tile theme
      listTileTheme: const ListTileThemeData(
        iconColor: _secondaryText,
        textColor: _primaryText,
        tileColor: _cardBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: _secondaryText.withOpacity(0.2),
        thickness: 1,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceColor,
        selectedItemColor: _auroraGreen,
        unselectedItemColor: _secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceColor,
        selectedColor: _auroraGreen.withOpacity(0.2),
        deleteIconColor: _auroraPink,
        labelStyle: const TextStyle(color: _primaryText),
        secondaryLabelStyle: const TextStyle(color: _primaryText),
        brightness: Brightness.dark,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Custom colors for direct access
  static const Color auroraGreen = _auroraGreen;
  static const Color auroraBlue = _auroraBlue;
  static const Color auroraPurple = _auroraPurple;
  static const Color auroraPink = _auroraPink;
  static const Color darkBackground = _darkBackground;
  static const Color cardBackground = _cardBackground;
  static const Color surfaceColor = _surfaceColor;
  static const Color primaryText = _primaryText;
  static const Color secondaryText = _secondaryText;
  static const Color accentText = _accentText;
}
