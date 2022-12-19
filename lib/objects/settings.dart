import 'package:colour_picker/objects/display.dart';
import 'package:colour_picker/objects/picker.dart';
import 'package:colour_picker/util/cornai.dart';

class Settings {
  PickerType picker;
  DisplayType display;
  DelniitColourType delniit_colour_format;
  bool delniit_full_words;
  bool include_alpha;
  bool hsv_sv_area;
  bool hsv_hs_wheel;
  bool rgb_gb_area;
  bool rgb_br_area;
  bool rgb_rg_area;

  Settings({
    PickerType? picker,
    DisplayType? display,
    DelniitColourType? delniit_colour_format,
    bool? delniit_full_words,
    bool? include_alpha,
    bool? hsv_sv_area,
    bool? hsv_hs_wheel,
    bool? rgb_gb_area,
    bool? rgb_br_area,
    bool? rgb_rg_area,
  })  : picker = picker ?? PickerType.delniit,
        display = display ?? DisplayType.delniit,
        delniit_colour_format = delniit_colour_format ?? DelniitColourType.cornai,
        delniit_full_words = delniit_full_words ?? false,
        include_alpha = include_alpha ?? true,
        hsv_sv_area = hsv_sv_area ?? true,
        hsv_hs_wheel = hsv_hs_wheel ?? false,
        rgb_gb_area = rgb_gb_area ?? true,
        rgb_br_area = rgb_br_area ?? true,
        rgb_rg_area = rgb_rg_area ?? true;
}
