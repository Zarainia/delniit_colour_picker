import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/constants.dart' as constants;
import 'package:colour_picker/cubits/settings_cubit.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/objects/settings.dart';
import 'package:colour_picker/util/cornai.dart';
import 'package:colour_picker/widgets/misc.dart';

class DelniitDisplaySettings extends StatelessWidget {
  const DelniitDisplaySettings();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);
    Iterable<Tuple2<DelniitColourType, String>> type_options = DelniitColourType.values.map((type) => Tuple2(type, type.display_name));
    TextStyle delniit_style = TextStyle(fontFamily: constants.DELNIIT_FONT, fontSize: 18);

    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) => ListView(
        children: [
          ListTile(
            title: DropdownButtonFormField(
              value: settings.delniit_colour_format,
              items: simple_menu_items(context, type_options, style: delniit_style, focus_colour: theme.primaryColor),
              selectedItemBuilder: simple_selected_menu_items(type_options),
              onChanged: (type) => context.read<SettingsCubit>().update_setting((shared_preferences) => shared_preferences.setString("delniit_colour_format", type!.name)),
              focusColor: Colors.transparent,
              style: delniit_style.copyWith(color: theme.colorScheme.onSurface),
              decoration: TextFieldBorder(
                focused_colour: theme.colorScheme.onSurface,
                context: context,
                labelText: "Mode",
              ),
            ),
          ),
          SwitchListTile(
            title: Text("Full words"),
            value: settings.delniit_full_words,
            onChanged: (full_words) => context.read<SettingsCubit>().update_setting((shared_preferences) => shared_preferences.setBool("delniit_full_words", full_words)),
            activeColor: theme.colorScheme.secondary,
          ),
        ],
        shrinkWrap: true,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class DelniitDisplay extends StatelessWidget {
  final TypedColour colour;
  final HSLColor hsl;

  DelniitDisplay(this.colour) : hsl = colour.to_hsl().hsl;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) => PlainDisplay(
        value: colour_to_delniit_string(hsl, type: settings.delniit_colour_format, full_words: settings.delniit_full_words),
        delniit: true,
        settings_popover: const DelniitDisplaySettings(),
      ),
    );
  }
}
