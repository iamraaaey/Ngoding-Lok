import 'package:flutter/material.dart';
import 'presentation/theme/doodle.dart';
import 'presentation/theme/landing_tokens.dart';

/// Global dark theme in the "terminal noir" language of the landing page:
/// near-black surfaces, hot ember primary, terminal-green secondary.
final ThemeData appTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: LandingTokens.voidBlack,
  colorScheme: const ColorScheme.dark(
    primary: LandingTokens.ember,
    secondary: LandingTokens.signal,
    surface: LandingTokens.carbon,
  ),
  dividerColor: LandingTokens.hairline,
);

/// Light counterpart used when the player flips the Dark/Light switch in
/// Settings. Screens that opt into theming read [Brightness] to swap their
/// backdrop and on-background text; the doodle cards stay white either way.
final ThemeData appLightTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: DoodlePalette.cream,
  colorScheme: const ColorScheme.light(
    primary: LandingTokens.ember,
    secondary: DoodlePalette.green,
  ),
);
