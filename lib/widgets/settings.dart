import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/cubits/settings_cubit.dart';
import 'package:colour_picker/objects/settings.dart';

class SettingsPopoverButton extends StatelessWidget {
  Widget content;

  SettingsPopoverButton({required this.content});

  @override
  Widget build(BuildContext context) {
    return PopoverButton(
      clickable_builder: (context, on_click) => IconButton(
        icon: const Icon(Icons.settings),
        onPressed: on_click,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.only(right: 5),
      ),
      overlay_contents: PopoverContentsWrapper(
        header: PopoverHeader(title: "Settings"),
        body: Padding(
          child: content,
          padding: EdgeInsets.only(top: 10),
        ),
      ),
    );
  }
}

class IncludeAlphaSetting extends StatelessWidget {
  final Settings settings;

  const IncludeAlphaSetting({required this.settings});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);

    return SwitchListTile(
      title: Text("Include alpha"),
      value: settings.include_alpha,
      onChanged: (alpha) => context.read<SettingsCubit>().update_setting((shared_preferences) => shared_preferences.setBool("include_alpha", alpha)),
      activeColor: theme.colorScheme.secondary,
    );
  }
}
