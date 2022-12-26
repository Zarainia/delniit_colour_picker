import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gradients/gradients.dart' hide ColorModel;
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/cubits/settings_cubit.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/objects/settings.dart';
import 'package:colour_picker/util/utils.dart';
import 'package:colour_picker/widgets/area.dart';
import 'package:colour_picker/widgets/painters.dart';
import 'package:colour_picker/widgets/settings.dart';
import 'package:colour_picker/widgets/slider.dart';

class _HSVWithHueColourPainter extends CustomPainter {
  final TypedColour colour;
  final HSVColor hsv;
  final ThemeData theme;

  _HSVWithHueColourPainter(this.colour, {required this.theme}) : hsv = colour.to_hsv().hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.saveLayer(Rect.largest, Paint());
    Gradient value_gradient = LinearGradientPainter(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        hsv.withSaturation(0).withValue(1).withAlpha(1).alt,
        hsv.withSaturation(0).withValue(0).withAlpha(1).alt,
      ],
      colorSpace: ColorSpace.hsb,
    );
    final Gradient saturation_gradient = LinearGradientPainter(
      colors: [
        hsv.withSaturation(0).withValue(1).withAlpha(1).alt,
        hsv.withSaturation(1).withValue(1).withAlpha(1).alt,
      ],
      colorSpace: ColorSpace.hsb,
    );
    canvas.drawRect(rect, Paint()..shader = value_gradient.createShader(rect));
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.multiply
        ..shader = saturation_gradient.createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.fill
        ..color = colour.colour
        ..blendMode = BlendMode.dstIn,
    );
    canvas.restore();

    paint_thumb(
      canvas: canvas,
      theme: theme,
      radius: AREA_THUMB_RADIUS,
      centre: Offset(size.width * hsv.saturation, size.height * (1 - hsv.value)),
      colour: colour.colour,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HSVPickerSettings extends StatelessWidget {
  const HSVPickerSettings();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);

    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) => ListView(
        children: [
          SwitchListTile(
            title: Text("Saturation-value area"),
            value: settings.hsv_sv_area,
            onChanged: (area) => context.read<SettingsCubit>().update_setting((shared_preferences) => shared_preferences.setBool("hsv_sv_area", area)),
            activeColor: theme.colorScheme.secondary,
          ),
          SwitchListTile(
            title: Text("Hue-saturation wheel"),
            value: settings.hsv_hs_wheel,
            onChanged: (wheel) => context.read<SettingsCubit>().update_setting((shared_preferences) => shared_preferences.setBool("hsv_hs_wheel", wheel)),
            activeColor: theme.colorScheme.secondary,
          ),
        ],
        shrinkWrap: true,
      ),
    );
  }
}

class HSVPicker extends StatelessWidget {
  final TypedColour curr_colour;
  final HSVColor hsv_colour;

  HSVPicker({required this.curr_colour}) : hsv_colour = curr_colour.to_hsv().hsv;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);

    return IntrinsicWidth(
      child: BlocBuilder<SettingsCubit, Settings>(
        builder: (context, settings) => Column(
          children: [
            Align(
              child: SettingsPopoverButton(content: const HSVPickerSettings()),
              alignment: Alignment.topRight,
            ),
            SliderRow(
              label: 'H',
              full_name: 'hue',
              model: ColorModel.hsv,
              track_type: TrackType.hue,
              maximum: 360,
              value: hsv_colour.hue,
              colour: curr_colour,
              colour_updater: (hue) => HSVType(hsv_colour.withHue(hue)),
              decimal: false,
            ),
            SliderRow(
              label: 'S',
              full_name: 'saturation',
              model: ColorModel.hsv,
              track_type: TrackType.saturationForHSL,
              maximum: 1,
              value: hsv_colour.saturation,
              colour: curr_colour,
              colour_updater: (sat) => HSVType(hsv_colour.withSaturation(sat)),
            ),
            SliderRow(
              label: 'V',
              full_name: 'value',
              model: ColorModel.hsv,
              track_type: TrackType.value,
              maximum: 1,
              value: hsv_colour.value,
              colour: curr_colour,
              colour_updater: (val) => HSVType(hsv_colour.withValue(val)),
            ),
            SliderRow(
              label: 'A',
              full_name: 'alpha',
              model: ColorModel.hsv,
              track_type: TrackType.alpha,
              maximum: 1,
              value: hsv_colour.alpha,
              colour: curr_colour,
              colour_updater: (alpha) => HSVType(hsv_colour.withAlpha(alpha)),
            ),
            if (settings.hsv_sv_area)
              SizedColourPickerArea(
                painter: _HSVWithHueColourPainter(curr_colour, theme: theme),
                colour_updater: (sat, val) => HSVType(hsv_colour.withSaturation(sat).withValue(val)),
                horizontal_label: 'V',
                vertical_label: 'S',
              ),
            if (settings.hsv_hs_wheel) SizedHueWheelArea(curr_colour: curr_colour),
          ],
        ),
      ),
    );
  }
}
