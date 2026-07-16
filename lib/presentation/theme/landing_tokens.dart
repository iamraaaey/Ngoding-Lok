import 'package:flutter/material.dart';

/// Design primitives for the Ngoding Lok "terminal noir" experience.
///
/// The visual language mimics modern AI/blockchain product sites: a
/// near-black page, hairline grid borders, monospace uppercase micro-labels,
/// one hot orange accent, and a single iridescent rainbow sweep reserved for
/// the hero robot. Keep landing-specific visual decisions here instead of
/// scattering literal values through widgets.
abstract final class LandingTokens {
  LandingTokens._();

  // Color

  /// Page background: almost black, slightly warm.
  static const Color voidBlack = Color(0xFF070707);

  /// Card / panel surfaces, from recessed to raised.
  static const Color carbon = Color(0xFF0C0C0C);
  static const Color panel = Color(0xFF101010);
  static const Color panelRaised = Color(0xFF161616);

  /// Hairline borders that draw the page grid.
  static const Color hairline = Color(0x1AFFFFFF);
  static const Color hairlineStrong = Color(0x33FFFFFF);

  static const Color textPrimary = Color(0xFFF4F3EF);
  static const Color textMuted = Color(0xFF908F88);
  static const Color textFaint = Color(0xFF56554F);

  /// The single hot accent. Use sparingly, like the reference.
  static const Color ember = Color(0xFFFF5C01);
  static const Color emberBright = Color(0xFFFF7A2F);
  static const Color emberDim = Color(0x2EFF5C01);

  /// Terminal signal green for status dots and success cues.
  static const Color signal = Color(0xFF43FFA4);

  /// Terminal cyan, the third and last permitted hue.
  static const Color circuit = Color(0xFF00E5FF);

  static const Color focusRing = Color(0xFFFFB166);

  /// Iridescent sweep for the hero bot screen, echoing the rainbow display
  /// of the reference robot. First and last colors match so a rotating
  /// gradient loops seamlessly.
  static const List<Color> iridescence = <Color>[
    Color(0xFF00E5FF),
    Color(0xFF7C4DFF),
    Color(0xFFFF4D9E),
    Color(0xFFFF5C01),
    Color(0xFFFFB300),
    Color(0xFF00FFA3),
    Color(0xFF00E5FF),
  ];

  static const LinearGradient iridescentGradient = LinearGradient(
    colors: iridescence,
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

  static const double contentMaxWidth = 1240;
  static const double readingMaxWidth = 640;
  static const double heroArtMaxWidth = 560;

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

  /// Size of the big boxed hero words.
  static double heroDisplaySizeFor(double width) {
    if (width >= wideBreakpoint) return 82;
    if (width >= desktopBreakpoint) return 66;
    if (width >= tabletBreakpoint) return 54;
    if (width >= compactBreakpoint) return 42;
    return 34;
  }

  // Shape

  /// Corners are deliberately near-sharp; the reference language is boxes
  /// and hairlines, not pills.
  static const double radiusSmall = 2;
  static const double radiusMedium = 4;
  static const double radiusLarge = 6;
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
    BoxShadow(color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 14)),
  ];

  static const List<BoxShadow> emberGlow = <BoxShadow>[
    BoxShadow(color: Color(0x40FF5C01), blurRadius: 26, offset: Offset(0, 6)),
  ];

  // Typography

  /// Monospace stack for labels, terminal copy, and metadata.
  static const String monoFontFamily = 'Consolas';
  static const List<String> monoFontFallback = <String>[
    'JetBrains Mono',
    'SF Mono',
    'Menlo',
    'Courier New',
    'monospace',
  ];

  /// Big display words lean on the platform grotesque with heavy weight and
  /// tight tracking, matching the reference headline.
  static TextStyle display({
    required double fontSize,
    Color color = textPrimary,
    FontWeight fontWeight = FontWeight.w800,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.0,
      letterSpacing: fontSize * -0.02,
    );
  }

  static TextStyle sectionTitle({
    required double fontSize,
    Color color = textPrimary,
  }) {
    return display(fontSize: fontSize, color: color).copyWith(height: 1.06);
  }

  static TextStyle body({
    double fontSize = 15,
    Color color = textMuted,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.6,
      letterSpacing: 0.1,
    );
  }

  /// Uppercase monospace micro-label, the signature type of this theme.
  static TextStyle label({
    double fontSize = 11,
    Color color = textMuted,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      color: color,
      fontFamily: monoFontFamily,
      fontFamilyFallback: monoFontFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.3,
      letterSpacing: 1.6,
    );
  }

  /// Terminal / code text.
  static TextStyle mono({
    double fontSize = 13,
    Color color = textPrimary,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return TextStyle(
      color: color,
      fontFamily: monoFontFamily,
      fontFamilyFallback: monoFontFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.55,
      letterSpacing: 0.2,
    );
  }

  // Motion

  static const Duration motionFast = Duration(milliseconds: 160);
  static const Duration motionStandard = Duration(milliseconds: 260);
  static const Duration motionSlow = Duration(milliseconds: 520);

  /// Returns zero when the platform's accessibility setting asks for reduced
  /// motion. Use this for every landing-page animation duration.
  static Duration motionFor(BuildContext context, Duration standardDuration) {
    return reducedMotion(context) ? Duration.zero : standardDuration;
  }

  /// Whether looping/ambient animations should be suppressed entirely.
  static bool reducedMotion(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }
}
