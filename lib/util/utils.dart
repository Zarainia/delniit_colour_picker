import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart' show ColorModel;
import 'package:gradients/gradients.dart' hide ColorModel;

import '../constants.dart' as constants;

extension ColourModelExtension on ColorModel {
  ColorSpace get colour_space => constants.COLOUR_SPACE_CONVERSIONS[this]!;
}

extension HSLColourExtension on HSLColor {
  HslColor get alt => HslColor(hue, (saturation * 100).round(), (lightness * 100).round(), (alpha * 255).round());
}

extension HSVColourExtension on HSVColor {
  HsbColor get alt => HsbColor(hue, (saturation * 100).round(), (value * 100).round(), (alpha * 255).round());
}

extension RGBColourExtension on Color {
  RgbColor get alt => RgbColor(red, green, blue, alpha);
}
