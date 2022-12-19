import 'package:flutter/material.dart';

import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/util/cornai.dart';
import 'package:colour_picker/util/utils.dart';

abstract class TypedColour {
  Color get colour;

  HSLType to_hsl() => this is HSLType ? this as HSLType : HSLType(HSLColor.fromColor(colour));

  HSVType to_hsv() => this is HSVType ? this as HSVType : HSVType(HSVColor.fromColor(colour));

  RGBType to_rgb() => this is RGBType ? this as RGBType : RGBType(colour);

  HexType to_hex() => this is HexType ? this as HexType : HexType(colour.toHex().replaceAll('#', ''));

  DelniitType to_delniit() => this is DelniitType ? this as DelniitType : DelniitType(colour_to_delniit_string(this.to_hsl().hsl));
}

class HSLType extends TypedColour {
  final Color colour;
  final HSLColor hsl;

  HSLType(this.hsl) : colour = hsl.alt;
}

class DelniitType extends HSLType {
  final String delniit;

  DelniitType(this.delniit) : super(parse_delniit_colour(delniit));
}

class HSVType extends TypedColour {
  final Color colour;
  final HSVColor hsv;

  HSVType(this.hsv) : colour = hsv.alt;
}

class RGBType extends TypedColour {
  final Color colour;

  RGBType(this.colour);
}

class HexType extends RGBType {
  String hex;

  HexType(this.hex) : super(colour_from_hex(hex));
}
