import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gradients/gradients.dart' hide ColorModel;
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/cubits/settings_cubit.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/objects/settings.dart';
import 'package:colour_picker/widgets/area.dart';
import 'package:colour_picker/widgets/painters.dart';
import 'package:colour_picker/widgets/settings.dart';
import 'package:colour_picker/widgets/slider.dart';

class _RGBWithRedColorPainter extends CustomPainter {
  final TypedColour colour;
  final Color rgb;
  final ThemeData theme;

  _RGBWithRedColorPainter(this.colour, {required this.theme}) : rgb = colour.colour;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.saveLayer(Rect.largest, Paint());
    final Gradient blue_gradient = LinearGradientPainter(
      colors: [
        Color.fromRGBO(rgb.red ~/ 2, 0, 0, 1.0),
        Color.fromRGBO(rgb.red ~/ 2, 0, 255, 1.0),
      ],
      colorSpace: ColorSpace.rgb,
    );
    final Gradient green_gradient = LinearGradientPainter(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromRGBO(rgb.red ~/ 2, 255, 0, 1.0),
        Color.fromRGBO(rgb.red ~/ 2, 0, 0, 1.0),
      ],
      colorSpace: ColorSpace.rgb,
    );
    canvas.drawRect(rect, Paint()..shader = blue_gradient.createShader(rect));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = green_gradient.createShader(rect)
        ..blendMode = BlendMode.plus,
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
      centre: Offset(size.width * rgb.blue / 255, size.height * (1 - rgb.green / 255)),
      colour: colour.colour,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _RGBWithGreenColorPainter extends CustomPainter {
  final TypedColour colour;
  final Color rgb;
  final ThemeData theme;

  _RGBWithGreenColorPainter(this.colour, {required this.theme}) : rgb = colour.colour;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.saveLayer(Rect.largest, Paint());
    final Gradient blue_gradient = LinearGradientPainter(
      colors: [
        Color.fromRGBO(0, rgb.green ~/ 2, 0, 1.0),
        Color.fromRGBO(0, rgb.green ~/ 2, 255, 1.0),
      ],
      colorSpace: ColorSpace.rgb,
    );
    final Gradient green_gradient = LinearGradientPainter(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromRGBO(255, rgb.green ~/ 2, 0, 1.0),
        Color.fromRGBO(0, rgb.green ~/ 2, 0, 1.0),
      ],
      colorSpace: ColorSpace.rgb,
    );
    canvas.drawRect(rect, Paint()..shader = blue_gradient.createShader(rect));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = green_gradient.createShader(rect)
        ..blendMode = BlendMode.plus,
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
      centre: Offset(size.width * rgb.blue / 255, size.height * (1 - rgb.red / 255)),
      colour: colour.colour,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _RGBWithBlueColorPainter extends CustomPainter {
  final TypedColour colour;
  final Color rgb;
  final ThemeData theme;

  _RGBWithBlueColorPainter(this.colour, {required this.theme}) : rgb = colour.colour;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.saveLayer(Rect.largest, Paint());
    final Gradient blue_gradient = LinearGradientPainter(
      colors: [
        Color.fromRGBO(0, 0, rgb.blue ~/ 2, 1.0),
        Color.fromRGBO(255, 0, rgb.blue ~/ 2, 1.0),
      ],
      colorSpace: ColorSpace.rgb,
    );
    final Gradient green_gradient = LinearGradientPainter(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromRGBO(0, 255, rgb.blue ~/ 2, 1.0),
        Color.fromRGBO(0, 0, rgb.blue ~/ 2, 1.0),
      ],
      colorSpace: ColorSpace.rgb,
    );
    canvas.drawRect(rect, Paint()..shader = blue_gradient.createShader(rect));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = green_gradient.createShader(rect)
        ..blendMode = BlendMode.plus,
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
      centre: Offset(size.width * rgb.red / 255, size.height * (1 - rgb.green / 255)),
      colour: colour.colour,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RGBPickerSettings extends StatelessWidget {
  const RGBPickerSettings();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);

    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) => ListView(
        children: [
          SwitchListTile(
            title: Text("Green-blue area"),
            value: settings.rgb_gb_area,
            onChanged: (area) => context.read<SettingsCubit>().update_setting((shared_preferences) => shared_preferences.setBool("rgb_gb_area", area)),
            activeColor: theme.colorScheme.secondary,
          ),
          SwitchListTile(
            title: Text("Blue-red area"),
            value: settings.rgb_br_area,
            onChanged: (area) => context.read<SettingsCubit>().update_setting((shared_preferences) => shared_preferences.setBool("rgb_br_area", area)),
            activeColor: theme.colorScheme.secondary,
          ),
          SwitchListTile(
            title: Text("Red-green area"),
            value: settings.rgb_rg_area,
            onChanged: (area) => context.read<SettingsCubit>().update_setting((shared_preferences) => shared_preferences.setBool("rgb_rg_area", area)),
            activeColor: theme.colorScheme.secondary,
          ),
        ],
        shrinkWrap: true,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class RGBPicker extends StatelessWidget {
  final TypedColour curr_colour;
  final Color rgb_colour;

  RGBPicker({required this.curr_colour}) : rgb_colour = curr_colour.colour;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);

    return IntrinsicWidth(
      child: BlocBuilder<SettingsCubit, Settings>(
        builder: (context, settings) => Column(
          children: [
            Align(
              child: SettingsPopoverButton(content: const RGBPickerSettings()),
              alignment: Alignment.topRight,
            ),
            SliderRow(
              label: 'R',
              full_name: 'red',
              model: ColorModel.rgb,
              track_type: TrackType.red,
              maximum: 255,
              value: rgb_colour.red.toDouble(),
              colour: curr_colour,
              colour_updater: (r) => RGBType(rgb_colour.withRed(r.toInt())),
              decimal: false,
            ),
            SliderRow(
              label: 'G',
              full_name: 'green',
              model: ColorModel.rgb,
              track_type: TrackType.green,
              maximum: 255,
              value: rgb_colour.green.toDouble(),
              colour: curr_colour,
              colour_updater: (g) => RGBType(rgb_colour.withGreen(g.toInt())),
              decimal: false,
            ),
            SliderRow(
              label: 'B',
              full_name: 'blue',
              model: ColorModel.rgb,
              track_type: TrackType.blue,
              maximum: 255,
              value: rgb_colour.blue.toDouble(),
              colour: curr_colour,
              colour_updater: (b) => RGBType(rgb_colour.withBlue(b.toInt())),
              decimal: false,
            ),
            SliderRow(
              label: 'A',
              full_name: 'alpha',
              model: ColorModel.rgb,
              track_type: TrackType.alpha,
              maximum: 1,
              value: rgb_colour.opacity,
              colour: curr_colour,
              colour_updater: (alpha) => RGBType(rgb_colour.withOpacity(alpha)),
            ),
            if (settings.rgb_gb_area)
              SizedColourPickerArea(
                painter: _RGBWithRedColorPainter(curr_colour, theme: theme),
                colour_updater: (blue, green) => RGBType(rgb_colour.withGreen((green * 255).round()).withBlue((blue * 255).round())),
                horizontal_label: 'G',
                vertical_label: 'B',
              ),
            if (settings.rgb_br_area)
              SizedColourPickerArea(
                painter: _RGBWithGreenColorPainter(curr_colour, theme: theme),
                colour_updater: (blue, red) => RGBType(rgb_colour.withRed((red * 255).round()).withBlue((blue * 255).round())),
                horizontal_label: 'B',
                vertical_label: 'R',
              ),
            if (settings.rgb_rg_area)
              SizedColourPickerArea(
                painter: _RGBWithBlueColorPainter(curr_colour, theme: theme),
                colour_updater: (red, green) => RGBType(rgb_colour.withRed((red * 255).round()).withGreen((green * 255).round())),
                horizontal_label: 'R',
                vertical_label: 'G',
              ),
          ],
        ),
      ),
    );
  }
}
