import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:colour_picker/objects/display.dart';
import 'package:colour_picker/objects/picker.dart';
import 'package:colour_picker/objects/settings.dart';
import 'package:colour_picker/util/cornai.dart';

class SettingsCubit extends Cubit<Settings> {
  SettingsCubit() : super(Settings()) {
    get_settings();
  }

  Future get_settings() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    emit(
      Settings(
        picker: preferences.containsKey("picker") ? PickerType.values.byName(preferences.getString("picker")!) : null,
        display: preferences.containsKey("display") ? DisplayType.values.byName(preferences.getString("display")!) : null,
        delniit_full_words: preferences.getBool("delniit_full_words"),
        delniit_colour_format: preferences.containsKey("delniit_colour_format") ? DelniitColourType.values.byName(preferences.getString("delniit_colour_format")!) : null,
        include_alpha: preferences.getBool("include_alpha"),
        hsv_sv_area: preferences.getBool("hsv_sv_area"),
        hsv_hs_wheel: preferences.getBool("hsv_hs_wheel"),
        rgb_br_area: preferences.getBool("rgb_br_area"),
        rgb_gb_area: preferences.getBool("rgb_gb_area"),
        rgb_rg_area: preferences.getBool("rgb_rg_area"),
      ),
    );
  }

  Future update_setting(Future Function(SharedPreferences shared_preferences) update_func) async {
    SharedPreferences shared_preferences = await SharedPreferences.getInstance();
    await update_func(shared_preferences);
    await get_settings();
  }
}
