import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gradients/gradients.dart' hide ColorModel;

const String DELNIIT_FONT = "TimesNewDelniit";

const double WORDS_TOGGLE_LOCATION_BREAKPOINT = 500;

const bool APPBAR_WORDS_TOGGLE = false;

const Map<ColorModel, ColorSpace> COLOUR_SPACE_CONVERSIONS = {
  ColorModel.hsl: ColorSpace.hsl,
  ColorModel.hsv: ColorSpace.hsb,
  ColorModel.rgb: ColorSpace.rgb,
};
