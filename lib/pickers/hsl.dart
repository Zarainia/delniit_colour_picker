import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gradients/gradients.dart' hide ColorModel;
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/util/utils.dart';
import 'package:colour_picker/widgets/area.dart';
import 'package:colour_picker/widgets/painters.dart';
import 'package:colour_picker/widgets/slider.dart';

class _HSLWithHueColourPainter extends CustomPainter {
  final TypedColour colour;
  final HSLColor hsl;
  final ThemeData theme;

  _HSLWithHueColourPainter(this.colour, {required this.theme}) : hsl = colour.to_hsl().hsl;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.saveLayer(Rect.largest, Paint());
    final Gradient saturation_gradient = LinearGradientPainter(
      colors: [
        hsl.withSaturation(0).withLightness(0.5).withAlpha(1).alt,
        hsl.withSaturation(1.0).withLightness(0.5).withAlpha(1).alt,
      ],
      colorSpace: ColorSpace.hsl,
    );
    Gradient lightness_gradient = LinearGradientPainter(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5],
      colors: [
        hsl.withLightness(1).withAlpha(1).alt,
        hsl.withAlpha(0).withLightness(1).alt,
      ],
      colorSpace: ColorSpace.hsl,
    );
    Gradient lightness_gradient2 = LinearGradientPainter(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.5, 1],
      colors: [
        hsl.withAlpha(0).withLightness(0).alt,
        hsl.withLightness(0).withAlpha(1).alt,
      ],
      colorSpace: ColorSpace.hsl,
    );
    canvas.drawRect(rect, Paint()..shader = saturation_gradient.createShader(rect));
    canvas.drawRect(rect, Paint()..shader = lightness_gradient.createShader(rect));
    canvas.drawRect(rect, Paint()..shader = lightness_gradient2.createShader(rect));
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
      centre: Offset(size.width * hsl.saturation, size.height * (1 - hsl.lightness)),
      colour: colour.colour,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HSLPicker extends StatelessWidget {
  final TypedColour curr_colour;
  final HSLColor hsl_colour;

  HSLPicker({required this.curr_colour}) : hsl_colour = curr_colour.to_hsl().hsl;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);

    return Column(
      children: [
        SliderRow(
          label: 'H',
          full_name: 'hue',
          model: ColorModel.hsl,
          track_type: TrackType.hue,
          maximum: 360,
          value: hsl_colour.hue,
          colour: curr_colour,
          colour_updater: (hue) => HSLType(hsl_colour.withHue(hue)),
          decimal: false,
        ),
        SliderRow(
          label: 'S',
          full_name: 'saturation',
          model: ColorModel.hsl,
          track_type: TrackType.saturationForHSL,
          maximum: 1,
          value: hsl_colour.saturation,
          colour: curr_colour,
          colour_updater: (sat) => HSLType(hsl_colour.withSaturation(sat)),
        ),
        SliderRow(
          label: 'L',
          full_name: 'lightness',
          model: ColorModel.hsl,
          track_type: TrackType.lightness,
          maximum: 1,
          value: hsl_colour.lightness,
          colour: curr_colour,
          colour_updater: (lightness) => HSLType(hsl_colour.withLightness(lightness)),
        ),
        SliderRow(
          label: 'A',
          full_name: 'alpha',
          model: ColorModel.hsl,
          track_type: TrackType.alpha,
          maximum: 1,
          value: hsl_colour.alpha,
          colour: curr_colour,
          colour_updater: (alpha) => HSLType(hsl_colour.withAlpha(alpha)),
        ),
        SizedColourPickerArea(
          painter: _HSLWithHueColourPainter(curr_colour, theme: theme),
          colour_updater: (sat, lightness) => HSLType(hsl_colour.withSaturation(sat).withLightness(lightness)),
          horizontal_label: 'L',
          vertical_label: 'S',
        ),
      ],
    );
  }
}
