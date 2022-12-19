import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/constants.dart' as constants;
import 'package:colour_picker/cubits/settings_cubit.dart';
import 'package:colour_picker/objects/display.dart';
import 'package:colour_picker/objects/picker.dart';
import 'package:colour_picker/objects/settings.dart';
import 'package:colour_picker/util/theme.dart';

class _LabeledSelector extends StatelessWidget {
  final Widget child;
  final IconData icon;

  const _LabeledSelector({required this.child, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        child,
      ],
    );
  }
}

class DisplaySelector extends StatelessWidget {
  const DisplaySelector();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);

    return _LabeledSelector(
      icon: Icons.desktop_windows,
      child: BlocBuilder<SettingsCubit, Settings>(
        builder: (context, settings) {
          Iterable<Tuple2<DisplayType, String>> options = DisplayType.values.map((e) => Tuple2(e, e.display_name));
          return IntrinsicWidth(
            child: DropdownButtonFormField(
              value: settings.display,
              items: simple_menu_items(context, options, style: TextStyle(fontFamily: constants.DELNIIT_FONT), focus_colour: theme.primaryColor),
              selectedItemBuilder: simple_selected_menu_items(options),
              onChanged: (display) => context.read<SettingsCubit>().update_setting((shared_preferences) => shared_preferences.setString("display", display!.name)),
              decoration: TextFieldBorder(focused_colour: theme.colorScheme.onBackground, context: context, isDense: true),
              style: TextStyle(fontSize: 15, color: theme.colorScheme.onBackground, fontFamily: constants.DELNIIT_FONT),
              focusColor: Colors.transparent,
            ),
          );
        },
      ),
    );
  }
}

class PickerSelector extends StatelessWidget {
  const PickerSelector();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);
    return _LabeledSelector(
      icon: Icons.palette,
      child: BlocBuilder<SettingsCubit, Settings>(
        builder: (context, settings) {
          Iterable<Tuple2<PickerType, String>> options = PickerType.values.map((e) => Tuple2(e, e.display_name));
          return IntrinsicWidth(
            child: DropdownButtonFormField(
              value: settings.picker,
              items: simple_menu_items(context, options, style: TextStyle(fontFamily: constants.DELNIIT_FONT), focus_colour: theme.primaryColor),
              selectedItemBuilder: simple_selected_menu_items(options),
              onChanged: (picker) => context.read<SettingsCubit>().update_setting((shared_preferences) => shared_preferences.setString("picker", picker!.name)),
              decoration: TextFieldBorder(focused_colour: theme.colorScheme.onBackground, context: context, isDense: true),
              style: TextStyle(fontSize: 15, color: theme.colorScheme.onBackground, fontFamily: constants.DELNIIT_FONT),
              focusColor: Colors.transparent,
            ),
          );
        },
      ),
    );
  }
}

class AppBarSelectors extends StatelessWidget {
  const AppBarSelectors();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);
    Color appbar_colour = theme.appBarTheme.backgroundColor!;
    ThemeData on_appbar_theme = generate_colour_based_theme(appbar_colour);

    return Container(
      child: ZarainiaThemeProvider(
        theme: "dark",
        background_colour: appbar_colour,
        primary_colour: on_appbar_theme.colorScheme.primary,
        secondary_colour: on_appbar_theme.colorScheme.secondary,
        builder: (context) => Theme(
          data: on_appbar_theme,
          child: Row(
            children: const [
              PickerSelector(),
              SizedBox(width: 20),
              DisplaySelector(),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
    );
  }
}
