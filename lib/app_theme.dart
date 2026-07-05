import 'package:flutter/material.dart';
import 'presentation/theme/doodle.dart';

final ThemeData appTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: DoodlePalette.dark,
  colorScheme: const ColorScheme.dark(primary: DoodlePalette.green, secondary: DoodlePalette.yellow),
);

/// Light counterpart used when the player flips the Dark/Light switch in
/// Settings. Screens that opt into theming read [Brightness] to swap their
/// backdrop and on-background text; the doodle cards stay white either way.
final ThemeData appLightTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: DoodlePalette.cream,
  colorScheme: const ColorScheme.light(primary: DoodlePalette.green, secondary: DoodlePalette.yellow),
);
