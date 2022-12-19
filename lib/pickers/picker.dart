import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:colour_picker/cubits/settings_cubit.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/objects/picker.dart';
import 'package:colour_picker/objects/settings.dart';
import 'package:colour_picker/pickers/delniit.dart';
import 'package:colour_picker/pickers/hex.dart';
import 'package:colour_picker/pickers/hsl.dart';
import 'package:colour_picker/pickers/hsv.dart';
import 'package:colour_picker/pickers/rgb.dart';

class PickerPage extends StatelessWidget {
  final TypedColour colour;

  PickerPage({required this.colour});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(builder: (context, settings) {
      switch (settings.picker) {
        case PickerType.hsl:
          return HSLPicker(curr_colour: colour);
        case PickerType.hsv:
          return HSVPicker(curr_colour: colour);
        case PickerType.rgb:
          return RGBPicker(curr_colour: colour);
        case PickerType.hex:
          return HexPicker(curr_colour: colour);
        case PickerType.delniit:
          return DelniitPicker(curr_colour: colour);
        default:
          throw UnimplementedError();
      }
    });
  }
}
