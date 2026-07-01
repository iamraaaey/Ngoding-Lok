import 'package:flutter/material.dart';
import 'presentation/theme/doodle.dart';

final ThemeData appTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: DoodlePalette.dark,
  colorScheme: const ColorScheme.dark(primary: DoodlePalette.green, secondary: DoodlePalette.yellow),
);
