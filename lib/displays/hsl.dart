import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:colour_picker/cubits/settings_cubit.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/objects/settings.dart';
import 'package:colour_picker/widgets/misc.dart';
import 'package:colour_picker/widgets/settings.dart';

class HSLDisplaySettings extends StatelessWidget {
  const HSLDisplaySettings();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) => ListView(
        children: [
          IncludeAlphaSetting(settings: settings),
        ],
        shrinkWrap: true,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class HSLDisplay extends StatelessWidget {
  final TypedColour colour;
  final HSLColor hsl;

  HSLDisplay(this.colour) : hsl = colour.to_hsl().hsl;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) => PlainDisplay(
        value: format_comma_value_string(
          values: [hsl.hue, hsl.saturation, hsl.lightness, if (settings.include_alpha) hsl.alpha],
          is_int: const [true, false, false, false],
        ),
        settings_popover: const HSLDisplaySettings(),
      ),
    );
  }
}
