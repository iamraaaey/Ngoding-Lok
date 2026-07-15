import 'package:flutter/material.dart';

/// Design primitives for the cinematic NgeCode Juh! marketing experience.
///
/// Keep landing-specific visual decisions here instead of scattering literal
/// values through widgets. Values are deliberately Flutter-only, so exported
/// Figma styles can be mapped here without introducing a font or UI package.
abstract final class LandingTokens {
  LandingTokens._();

  // Color

  static const Color midnight = Color(0xFF14112B);
  static const Color indigo = Color(0xFF392D62);
  static const Color violet = Color(0xFF7654A4);
  static const Color sunrise = Color(0xFFF28E5B);
  static const Color sunlight = Color(0xFFFFC36D);

  static const Color cream = Color(0xFFFFF8F0);
  static const Color creamMuted = Color(0xFFCFC7CC);
  static const Color ink = Color(0xFF171225);
  static const Color surface = Color(0xB314112B);
  static const Color surfaceStrong = Color(0xE61C1739);
  static const Color surfaceLight = Color(0x1AFFF8F0);
  static const Color outline = Color(0x42FFF8F0);
  static const Color focusRing = Color(0xFFFFD166);

  // Retain the product's playful game language as small, intentional accents.
  static const Color gameGreen = Color(0xFF06D6A0);
  static const Color gameYellow = Color(0xFFFFD166);
  static const Color gamePink = Color(0xFFEF476F);
  static const Color gameBlue = Color(0xFF118AB2);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[midnight, indigo, violet, sunrise, sunlight],
    stops: <double>[0, 0.36, 0.62, 0.84, 1],
  );

  static const LinearGradient primaryActionGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[sunrise, sunlight],
  );

  static const RadialGradient heroGlow = RadialGradient(
    center: Alignment(0.72, -0.56),
    radius: 1.1,
    colors: <Color>[Color(0x66FFC36D), Color(0x007654A4)],
    stops: <double>[0, 1],
  );

  // Spacing

  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;
  static const double space80 = 80;
  static const double space96 = 96;
  static const double space120 = 120;

  static const double contentMaxWidth = 1200;
  static const double readingMaxWidth = 680;
  static const double heroArtMaxWidth = 580;

  // Breakpoints

  static const double compactBreakpoint = 390;
  static const double tabletBreakpoint = 680;
  static const double desktopBreakpoint = 1024;
  static const double wideBreakpoint = 1280;

  static bool isCompact(double width) => width < compactBreakpoint;
  static bool isMobile(double width) => width < tabletBreakpoint;
  static bool isDesktop(double width) => width >= desktopBreakpoint;
  static bool isWide(double width) => width >= wideBreakpoint;

  static EdgeInsets pagePaddingFor(double width) {
    if (width >= wideBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 64);
    }
    if (width >= tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 40);
    }
    return const EdgeInsets.symmetric(horizontal: 20);
  }

  static double sectionVerticalPaddingFor(double width) {
    return width >= tabletBreakpoint ? space96 : space64;
  }

  static int moduleColumnsFor(double width) {
    if (width >= desktopBreakpoint) return 3;
    if (width >= tabletBreakpoint) return 2;
    return 1;
  }

  static double heroDisplaySizeFor(double width) {
    if (width >= wideBreakpoint) return 76;
    if (width >= desktopBreakpoint) return 64;
    if (width >= tabletBreakpoint) return 56;
    if (width >= compactBreakpoint) return 48;
    return 42;
  }

  // Shape and elevation

  static const double radiusSmall = 12;
  static const double radiusMedium = 20;
  static const double radiusLarge = 28;
  static const double radiusPill = 999;

  static const BorderRadius smallRadius = BorderRadius.all(
    Radius.circular(radiusSmall),
  );
  static const BorderRadius mediumRadius = BorderRadius.all(
    Radius.circular(radiusMedium),
  );
  static const BorderRadius largeRadius = BorderRadius.all(
    Radius.circular(radiusLarge),
  );
  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(radiusPill),
  );

  static const List<BoxShadow> cardShadow = <BoxShadow>[
    BoxShadow(color: Color(0x33100824), blurRadius: 32, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x14FFF8F0), blurRadius: 1, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> heroArtShadow = <BoxShadow>[
    BoxShadow(color: Color(0x66100824), blurRadius: 56, offset: Offset(0, 28)),
    BoxShadow(color: Color(0x26FFC36D), blurRadius: 40, spreadRadius: -8),
  ];

  static const List<BoxShadow> actionShadow = <BoxShadow>[
    BoxShadow(color: Color(0x5CF28E5B), blurRadius: 22, offset: Offset(0, 10)),
  ];

  // Typography

  /// Replace these family names with the exported Figma/Canva font families
  /// after they are registered in pubspec.yaml. The fallback lists preserve a
  /// polished editorial/UI pairing until then.
  static const String displayFontFamily = 'Georgia';
  static const List<String> displayFontFallback = <String>[
    'Times New Roman',
    'serif',
  ];
  static const String uiFontFamily = 'Arial';
  static const List<String> uiFontFallback = <String>[
    'Helvetica Neue',
    'sans-serif',
  ];

  static TextStyle display({
    required double fontSize,
    Color color = cream,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      color: color,
      fontFamily: displayFontFamily,
      fontFamilyFallback: displayFontFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 0.98,
      letterSpacing: -1.6,
    );
  }

  static TextStyle sectionTitle({
    required double fontSize,
    Color color = cream,
  }) {
    return display(fontSize: fontSize, color: color).copyWith(height: 1.04);
  }

  static TextStyle body({
    double fontSize = 16,
    Color color = creamMuted,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      color: color,
      fontFamily: uiFontFamily,
      fontFamilyFallback: uiFontFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.55,
      letterSpacing: 0.05,
    );
  }

  static TextStyle label({
    double fontSize = 13,
    Color color = cream,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      color: color,
      fontFamily: uiFontFamily,
      fontFamilyFallback: uiFontFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.2,
      letterSpacing: 0.8,
    );
  }

  // Motion

  static const Duration motionFast = Duration(milliseconds: 160);
  static const Duration motionStandard = Duration(milliseconds: 260);
  static const Duration motionSlow = Duration(milliseconds: 520);

  /// Returns zero when the platform's accessibility setting asks for reduced
  /// motion. Use this for every landing-page animation duration.
  static Duration motionFor(BuildContext context, Duration standardDuration) {
    final mediaQuery = MediaQuery.maybeOf(context);
    return mediaQuery?.disableAnimations ?? false
        ? Duration.zero
        : standardDuration;
  }
}
