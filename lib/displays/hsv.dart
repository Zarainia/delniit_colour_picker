import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:colour_picker/cubits/settings_cubit.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/objects/settings.dart';
import 'package:colour_picker/widgets/misc.dart';
import 'package:colour_picker/widgets/settings.dart';

class HSVDisplaySettings extends StatelessWidget {
  const HSVDisplaySettings();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) => ListView(
        children: [
          IncludeAlphaSetting(settings: settings),
        ],
        shrinkWrap: true,
      ),
    );
  }
}

class HSVDisplay extends StatelessWidget {
  final TypedColour colour;
  final HSVColor hsv;

  HSVDisplay(this.colour) : hsv = colour.to_hsv().hsv;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) => PlainDisplay(
        value: format_comma_value_string(
          values: [hsv.hue, hsv.saturation, hsv.value, if (settings.include_alpha) hsv.alpha],
          is_int: const [true, false, false, false],
        ),
        settings_popover: const HSVDisplaySettings(),
      ),
    );
  }
}
