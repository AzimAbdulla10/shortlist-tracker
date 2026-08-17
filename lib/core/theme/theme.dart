import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // exact hex colors derived from Bauhaus Stitch design
  static const Color bgCream = Color(0xFFF5F0E8); // Screen background
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Cards and input fields
  static const Color borderBlack = Color(0xFF1A1A1A); // Outlines and shadows
  
  static const Color accentYellow = Color(0xFFFFCC00); // Yellow highlight
  static const Color accentBlue = Color(0xFF0055FF); // Blue tag/button
  static const Color accentRed = Color(0xFFE63B2E); // Red warning tag
  
  static const Color textPrimary = Color(0xFF1A1A1A); // Dark charcoal text
  static const Color textSecondary = Color(0xFF4A4A4A); // Muted grey text
  static const Color borderMuted = Color(0xFFD0CBC3); // Subtler outlines if needed

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgCream,
      primaryColor: borderBlack,
      colorScheme: const ColorScheme.light(
        primary: borderBlack,
        secondary: accentYellow,
        tertiary: accentBlue,
        surface: surfaceWhite,
        error: accentRed,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      // Text theme with Space Grotesk (headings) and Inter (body)
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(fontSize: 40, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.8),
        headlineMedium: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textPrimary, height: 1.4),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textSecondary, height: 1.4),
        labelLarge: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgCream,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: textPrimary),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
    );
  }

  // Alias for compatibility to avoid refactoring main.dart
  static ThemeData get darkTheme => lightTheme;
}

// Custom Bauhaus/Neo-Brutalist Box Container
class NeoBox extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color shadowColor;
  final double borderWidth;
  final double shadowOffset;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const NeoBox({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.shadowColor = AppTheme.borderBlack,
    this.borderWidth = 3.0,
    this.shadowOffset = 4.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: AppTheme.borderBlack, width: borderWidth),
        boxShadow: shadowOffset > 0
            ? [
                BoxShadow(
                  color: shadowColor,
                  offset: Offset(shadowOffset, shadowOffset),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

// Custom Bauhaus/Neo-Brutalist Action Button
class NeoButton extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final double shadowOffset;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;

  const NeoButton({
    super.key,
    required this.child,
    this.backgroundColor = AppTheme.accentYellow,
    this.onTap,
    this.shadowOffset = 4.0,
    this.borderWidth = 3.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeoBox(
        backgroundColor: backgroundColor,
        shadowOffset: onTap != null ? shadowOffset : 0.0,
        borderWidth: borderWidth,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: child,
      ),
    );
  }
}
