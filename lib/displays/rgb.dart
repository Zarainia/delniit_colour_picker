import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:colour_picker/cubits/settings_cubit.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/objects/settings.dart';
import 'package:colour_picker/widgets/misc.dart';
import 'package:colour_picker/widgets/settings.dart';

class RGBDisplaySettings extends StatelessWidget {
  const RGBDisplaySettings();

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

class RGBDisplay extends StatelessWidget {
  final TypedColour colour;

  const RGBDisplay(this.colour);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) => PlainDisplay(
        value: format_comma_value_string(
          values: [colour.colour.red, colour.colour.green, colour.colour.blue, if (settings.include_alpha) colour.colour.alpha],
          is_int: const [true, true, true, true],
        ),
        settings_popover: const RGBDisplaySettings(),
      ),
    );
  }
}
