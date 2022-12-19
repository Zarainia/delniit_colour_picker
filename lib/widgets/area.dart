import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradients/gradients.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/cubits/colour_cubit.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/util/utils.dart';
import 'misc.dart';
import 'painters.dart';

const double AREA_THUMB_RADIUS = 13;

class _ColourPickerArea extends StatelessWidget {
  final Function(double, double) on_change;
  final CustomPainter painter;
  final bool is_hue_wheel;

  const _ColourPickerArea({
    required this.on_change,
    required this.painter,
    this.is_hue_wheel = false,
  });

  void _handle_gesture(Offset position, BuildContext context, double height, double width) {
    RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    Offset local_offset = box.globalToLocal(position);
    double horizontal = local_offset.dx.clamp(0.0, width);
    double vertical = local_offset.dy.clamp(0.0, height);

    if (is_hue_wheel) {
      Offset centre = Offset(width / 2, height / 2);
      double radio = width <= height ? width / 2 : height / 2;
      double dist = sqrt(pow(horizontal - centre.dx, 2) + pow(vertical - centre.dy, 2)) / radio;
      double rad = (atan2(horizontal - centre.dx, vertical - centre.dy) / pi + 1) / 2 * 360;
      on_change(((rad + 90) % 360).clamp(0, 360), dist.clamp(0, 1));
    } else {
      on_change(horizontal / width, 1 - vertical / height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        return RawGestureDetector(
          gestures: {
            AlwaysWinPanGestureRecognizer: GestureRecognizerFactoryWithHandlers<AlwaysWinPanGestureRecognizer>(
              () => AlwaysWinPanGestureRecognizer(),
              (AlwaysWinPanGestureRecognizer instance) {
                instance
                  ..onDown = ((details) => _handle_gesture(details.globalPosition, context, height, width))
                  ..onUpdate = ((details) => _handle_gesture(details.globalPosition, context, height, width));
              },
            ),
          },
          child: Builder(
            builder: (BuildContext _) {
              return CustomPaint(painter: painter);
            },
          ),
        );
      },
    );
  }
}

class SizedColourPickerArea extends StatelessWidget {
  final TypedColour Function(double h, double v) colour_updater;
  final CustomPainter painter;
  final String? horizontal_label;
  final String? vertical_label;

  SizedColourPickerArea({required this.colour_updater, required this.painter, this.horizontal_label, this.vertical_label});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double area_width = clampDouble(500, width * 0.3, width * 0.87);
    double area_height = clampDouble(area_width * 0.7, 150, 300);

    ThemeData theme = get_themedata(context);
    TextStyle axis_label_style = TextStyle(color: Color.lerp(theme.colorScheme.onBackground, null, theme.backgroundColor.brightness == Brightness.light ? 0.6 : 0.4));
    Widget horizontal_axis = Padding(
      child: Text(horizontal_label ?? '', style: axis_label_style),
      padding: const EdgeInsets.only(right: 7),
    );
    Widget vertical_axis = Padding(
      child: Text(vertical_label ?? '', style: axis_label_style),
      padding: const EdgeInsets.only(bottom: 5),
    );

    return Padding(
      child: Column(
        children: [
          if (vertical_label != null) vertical_axis,
          Row(
            children: [
              if (horizontal_label != null) horizontal_axis,
              Container(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: BackgroundGridPainter(grid_size: const Size(15, 15)),
                      ),
                    ),
                    Positioned.fill(
                      child: _ColourPickerArea(
                        painter: painter,
                        on_change: (sat, lightness) => context.read<ColourCubit>().update_colour(colour_updater(sat, lightness)),
                      ),
                    ),
                  ],
                ),
                width: area_width,
                height: area_height,
                decoration: BoxDecoration(border: Border.all(color: theme.dividerColor)),
              ),
              if (horizontal_label != null) HideKeepSpace(child: horizontal_axis),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 20),
    );
  }
}

class _HueColourWheelPainter extends CustomPainter {
  static const List<double> HUE_STOPS = [360, 300, 240, 180, 120, 60, 0];

  final TypedColour colour;
  final HSVColor hsv;
  final ThemeData theme;

  _HueColourWheelPainter(this.colour, {required this.theme}) : hsv = colour.to_hsv().hsv;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.largest, Paint());
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.height, size.height),
        Radius.circular(size.height / 2),
      ),
    );
    paint_transparency_grid(canvas: canvas, total_size: Size(size.height, size.height), grid_size: const Size(15, 15));
    canvas.restore();

    Rect rect = Offset.zero & size;
    Offset centre = Offset(size.width / 2, size.height / 2);
    double radius = size.width <= size.height ? size.width / 2 : size.height / 2;

    final List<Color> colors = HUE_STOPS.map((hue) => HsbColor(hue, 100, hsv.value * 100)).toList();
    final Gradient sweep_gradient = SweepGradientPainter(colors: colors, colorSpace: ColorSpace.hsb);
    Gradient radial_gradient = RadialGradientPainter(
      colors: [
        hsv.withSaturation(0).withAlpha(1).alt,
        hsv.withSaturation(0).withAlpha(0).alt,
      ],
      colorSpace: ColorSpace.hsb,
    );

    canvas.saveLayer(Rect.largest, Paint());
    canvas.drawCircle(centre, radius, Paint()..shader = sweep_gradient.createShader(rect));
    canvas.drawCircle(centre, radius, Paint()..shader = radial_gradient.createShader(rect));
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.fill
        ..color = colour.colour
        ..blendMode = BlendMode.dstIn,
    );
    canvas.restore();

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = theme.dividerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    paint_thumb(
      canvas: canvas,
      theme: theme,
      radius: AREA_THUMB_RADIUS,
      centre: Offset(
        centre.dx + hsv.saturation * radius * cos((hsv.hue * pi / 180)),
        centre.dy - hsv.saturation * radius * sin((hsv.hue * pi / 180)),
      ),
      colour: colour.colour,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SizedHueWheelArea extends StatelessWidget {
  TypedColour curr_colour;

  SizedHueWheelArea({required this.curr_colour});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double area_width = clampDouble(500, width * 0.25, width * 0.8);
    ThemeData theme = get_themedata(context);

    return Container(
      child: _ColourPickerArea(
        painter: _HueColourWheelPainter(curr_colour, theme: theme),
        on_change: (hue, sat) => context.read<ColourCubit>().update_colour(HSVType(curr_colour.to_hsv().hsv.withHue(hue).withSaturation(sat))),
        is_hue_wheel: true,
      ),
      width: area_width,
      height: area_width,
      margin: const EdgeInsets.only(top: 20),
    );
  }
}
