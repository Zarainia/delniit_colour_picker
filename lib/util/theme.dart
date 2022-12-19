import 'package:flutter/material.dart';

import 'package:zarainia_utils/zarainia_utils.dart';

ThemeData generate_colour_based_theme(Color main_colour) {
  Color background = get_colour_on_background(main_colour);
  Color contrasting_colour = background.contrasting_colour;
  Brightness brightness = background.brightness;
  Color dimmer_colour = brightness == Brightness.light ? Colors.white : Colors.black;
  ThemeData default_theme = brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();

  Color error_colour = Color.lerp(default_theme.errorColor, contrasting_colour, 0.3)!;
  if (colour_distance(background, error_colour) < 110) error_colour = Color.lerp(Colors.yellow, contrasting_colour, 0.3)!;

  Color colour_on_white = Color.alphaBlend(main_colour, Colors.white);
  Color appbar_colour = Color.lerp(colour_on_white, colour_on_white.contrasting_colour, 0.2)!;

  Color surface_colour = Color.lerp(colour_on_white, dimmer_colour, 0.2)!;

  Color primary_colour = Color.lerp(background, contrasting_colour, 0.3)!;
  Color alternate_colour = background.invert();

  return ThemeData(
    brightness: brightness,
    backgroundColor: background,
    canvasColor: background,
    primaryColor: primary_colour,
    focusColor: primary_colour,
    toggleableActiveColor: primary_colour,
    errorColor: error_colour,
    dividerColor: Color.lerp(contrasting_colour, null, brightness == Brightness.dark ? 0.6 : 0.7),
    dialogBackgroundColor: surface_colour,
    colorScheme: default_theme.colorScheme.copyWith(
      primary: primary_colour,
      secondary: alternate_colour,
      tertiary: alternate_colour,
      background: background,
      surface: surface_colour,
      error: error_colour,
      onBackground: contrasting_colour,
      onSurface: contrasting_colour,
    ),
    appBarTheme: AppBarTheme(color: appbar_colour, foregroundColor: appbar_colour.contrasting_colour),
    iconTheme: IconThemeData(color: contrasting_colour, opacity: brightness == Brightness.dark ? 0.6 : 0.4),
    hoverColor: Color.lerp(contrasting_colour, null, brightness == Brightness.dark ? 0.9 : 0.95),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Color.lerp(primary_colour, contrasting_colour, 0.5),
      selectionColor: Color.lerp(contrasting_colour, null, brightness == Brightness.dark ? 0.75 : 0.85),
      selectionHandleColor: primary_colour,
    ),
    inputDecorationTheme: InputDecorationTheme(labelStyle: TextStyle(color: contrasting_colour)),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface_colour,
      contentTextStyle: TextStyle(color: contrasting_colour),
    ),
  );
}

Color get_colour_on_background(Color colour) => Color.alphaBlend(colour, Colors.grey[100]!);
