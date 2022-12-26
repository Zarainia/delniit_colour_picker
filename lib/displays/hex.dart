import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:colour_picker/cubits/settings_cubit.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/objects/settings.dart';
import 'package:colour_picker/widgets/misc.dart';
import 'package:colour_picker/widgets/settings.dart';

class HexDisplaySettings extends StatelessWidget {
  const HexDisplaySettings();

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

class HexDisplay extends StatelessWidget {
  final TypedColour colour;
  final String hex;

  HexDisplay(this.colour) : hex = colour.to_hex().hex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) {
        String display_hex = hex.toUpperCase().padLeft(8, 'F');
        if (!settings.include_alpha) display_hex = display_hex.substring(2);

        return PlainDisplay(
          value: '#' + display_hex,
          settings_popover: const HexDisplaySettings(),
        );
      },
    );
  }
}
