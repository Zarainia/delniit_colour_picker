import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:colour_picker/cubits/settings_cubit.dart';
import 'package:colour_picker/displays/delniit.dart';
import 'package:colour_picker/displays/hex.dart';
import 'package:colour_picker/displays/hsl.dart';
import 'package:colour_picker/displays/hsv.dart';
import 'package:colour_picker/displays/rgb.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/objects/display.dart';
import 'package:colour_picker/objects/settings.dart';

class DisplayPage extends StatelessWidget {
  final TypedColour colour;

  DisplayPage({required this.colour});

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: BlocBuilder<SettingsCubit, Settings>(builder: (context, settings) {
        switch (settings.display) {
          case DisplayType.delniit:
            return DelniitDisplay(colour);
          case DisplayType.hsl:
            return HSLDisplay(colour);
          case DisplayType.hsv:
            return HSVDisplay(colour);
          case DisplayType.rgb:
            return RGBDisplay(colour);
          case DisplayType.hex:
            return HexDisplay(colour);
          default:
            throw UnimplementedError();
        }
      }),
      padding: const EdgeInsets.only(top: 40, bottom: 20),
    );
  }
}
