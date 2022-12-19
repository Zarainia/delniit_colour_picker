import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gradients/gradients.dart' hide ColorModel;
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/constants.dart' as constants;
import 'package:colour_picker/cubits/colour_cubit.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/util/cornai.dart';
import 'package:colour_picker/util/utils.dart';
import 'package:colour_picker/widgets/area.dart';
import 'package:colour_picker/widgets/painters.dart';
import 'misc.dart';

class _ThumbPainter extends CustomPainter {
  final Color? colour;
  final ThemeData theme;
  final String? text;

  const _ThumbPainter({required this.theme, this.colour, this.text});

  @override
  void paint(Canvas canvas, Size size) {
    Offset centre = Offset(0, size.height * 0.4);
    paint_thumb(canvas: canvas, theme: theme, radius: size.height, colour: colour, centre: centre);
    if (text != null) paint_slider_thumb_label(canvas: canvas, offset: centre, colour: colour!, text: text!);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _SliderLayout extends MultiChildLayoutDelegate {
  static const String track = 'track';
  static const String thumb = 'thumb';
  static const String gesture_container = 'gesture_container';

  @override
  void performLayout(Size size) {
    layoutChild(
      track,
      BoxConstraints.tightFor(
        width: size.width - 30.0,
        height: size.height / 5,
      ),
    );
    positionChild(track, Offset(15.0, size.height * 0.4));
    layoutChild(
      thumb,
      BoxConstraints.tightFor(width: 5.0, height: size.height / 4),
    );
    positionChild(thumb, Offset(0.0, size.height * 0.4));
    layoutChild(
      gesture_container,
      BoxConstraints.tightFor(width: size.width, height: size.height),
    );
    positionChild(gesture_container, Offset.zero);
  }

  @override
  bool shouldRelayout(_SliderLayout oldDelegate) => false;
}

class _TrackPainter extends CustomPainter {
  static const List<double> HUE_STOPS = [0, 60, 120, 180, 240, 300, 360];
  static const List<double> SATURATION_STOPS = [0, 1];
  static const List<double> VALUE_STOPS = [0, 1];
  static const List<double> LIGHTNESS_STOPS = [0, 0.5, 1];
  static const List<int> RGB_STOPS = [0, 255];
  static const List<double> ALPHA_STOPS = [0, 1];

  final ThemeData theme;
  final ColorModel colour_model;
  final TrackType track_type;
  final TypedColour colour;
  final bool discrete;

  const _TrackPainter({required this.theme, required this.colour_model, required this.track_type, required this.colour, this.discrete = false});

  static bool is_current_value(double value, int i, {int total = 10, double degrees_per_stop = 0.1}) {
    if (i == 0)
      return value < degrees_per_stop / 2;
    else if (i == total)
      return value > 1 - degrees_per_stop / 2;
    else {
      double base = i * degrees_per_stop;
      return base > value - degrees_per_stop / 2 && base < value + degrees_per_stop / 2;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    RRect border_rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(50),
    );
    canvas.saveLayer(Rect.largest, Paint());
    canvas.clipRRect(border_rrect);
    paint_transparency_grid(canvas: canvas, total_size: size, grid_size: Size(size.height / 2, size.height / 2));

    List<Color> colours;
    switch (track_type) {
      case TrackType.hue:
        assert(colour_model == ColorModel.hsv || colour_model == ColorModel.hsl);
        if (colour_model == ColorModel.hsv) {
          HSVColor hsv = colour.to_hsv().hsv;
          colours = [for (double hue in HUE_STOPS) hsv.withHue(hue).alt];
        } else {
          HSLColor hsl = colour.to_hsl().hsl;
          colours = [for (double hue in HUE_STOPS) hsl.withHue(hue).alt];
        }

        break;
      case TrackType.saturation:
      case TrackType.saturationForHSL:
        assert(colour_model == ColorModel.hsv || colour_model == ColorModel.hsl);
        if (colour_model == ColorModel.hsv) {
          HSVColor hsv = colour.to_hsv().hsv;
          colours = [for (double sat in SATURATION_STOPS) hsv.withSaturation(sat).alt];
        } else {
          HSLColor hsl = colour.to_hsl().hsl;
          colours = [for (double sat in SATURATION_STOPS) hsl.withSaturation(sat).alt];
        }
        break;
      case TrackType.value:
        assert(colour_model == ColorModel.hsv);
        HSVColor hsv = colour.to_hsv().hsv;
        colours = [for (double value in VALUE_STOPS) hsv.withValue(value).alt];
        break;
      case TrackType.lightness:
        assert(colour_model == ColorModel.hsl);
        HSLColor hsl = colour.to_hsl().hsl;
        colours = [for (double lightness in LIGHTNESS_STOPS) hsl.withLightness(lightness).alt];
        break;
      case TrackType.red:
        colours = [for (int r in RGB_STOPS) colour.colour.withRed(r).alt];
        break;
      case TrackType.green:
        colours = [for (int g in RGB_STOPS) colour.colour.withGreen(g).alt];
        break;
      case TrackType.blue:
        colours = [for (int b in RGB_STOPS) colour.colour.withBlue(b).alt];
        break;
      case TrackType.alpha:
        switch (colour_model) {
          case ColorModel.hsv:
            HSVColor hsv = colour.to_hsv().hsv;
            colours = [for (double alpha in ALPHA_STOPS) hsv.withAlpha(alpha).alt];
            break;
          case ColorModel.hsl:
            HSLColor hsl = colour.to_hsl().hsl;
            colours = [for (double alpha in ALPHA_STOPS) hsl.withAlpha(alpha).alt];
            break;
          case ColorModel.rgb:
            colours = [for (double alpha in ALPHA_STOPS) colour.colour.withOpacity(alpha)];
            break;
        }
        break;
    }
    Gradient gradient = LinearGradientPainter(colors: colours, colorSpace: colour_model.colour_space);
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    canvas.restore();

    canvas.drawRRect(
      border_rrect,
      Paint()
        ..color = theme.dividerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (discrete) {
      int stops = track_type == TrackType.lightness ? 20 : 10;
      double degrees_per_stop = 1 / stops;
      double offset_per_stop = degrees_per_stop * rect.width;
      HSLColor hsl = colour.to_hsl().hsl;

      for (int i = 0; i < stops + 1; i++) {
        bool current;
        Color colour;

        switch (track_type) {
          case TrackType.saturation:
          case TrackType.saturationForHSL:
            current = is_current_value(hsl.saturation, i);
            colour = hsl.withSaturation(i * degrees_per_stop).alt;
            break;
          case TrackType.lightness:
            current = is_current_value(hsl.lightness, i, total: 20, degrees_per_stop: degrees_per_stop);
            colour = hsl.withLightness(i * degrees_per_stop).alt;
            break;
          case TrackType.alpha:
            current = is_current_value(hsl.alpha, i);
            colour = hsl.withAlpha(i * degrees_per_stop).alt;
            break;
          default:
            throw UnimplementedError();
        }

        Offset offset = rect.centerLeft + Offset(offset_per_stop * i, 0);

        if (!current && i != 0 && i != stops) {
          if (i == 10 && track_type == TrackType.lightness)
            paint_slider_label(canvas: canvas, offset: offset, colour: colour, text: '✴');
          else
            paint_slider_tick(
              canvas: canvas,
              offset: offset,
              colour: colour,
              highlighted: track_type == TrackType.lightness && i == 10,
              intensity: 1 - colour.opacity,
            );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ColourPickerSlider extends StatelessWidget {
  final ColorModel colour_model;
  final TrackType track_type;
  final double maximum;
  final double value;
  final TypedColour colour;
  final ValueChanged<double> on_change;
  final bool discrete;
  final int? steps;
  final bool show_cornai;

  const ColourPickerSlider({
    super.key,
    required this.colour_model,
    required this.track_type,
    required this.maximum,
    required this.value,
    required this.colour,
    required this.on_change,
    this.discrete = false,
    this.steps,
    this.show_cornai = false,
  });

  void slide_event(RenderBox render_box, BoxConstraints constraints, Offset global_position) {
    double local_dx = render_box.globalToLocal(global_position).dx - 15.0;
    double progress = local_dx.clamp(0.0, constraints.maxWidth - 30.0) / (constraints.maxWidth - 30.0);
    if (discrete) {
      int step = (progress * steps!).round();
      on_change(step / steps! * maximum);
    } else
      on_change(progress * maximum);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints box) {
      ThemeData theme = get_themedata(context);
      double thumb_offset = 15.0 + (box.maxWidth - 30.0) * value / maximum;

      String? thumb_text;
      if (discrete && show_cornai) {
        int degrees = (value / maximum * steps!).round();
        if (track_type == TrackType.lightness) {
          if (degrees <= 10)
            degrees = 10 - degrees;
          else
            degrees = degrees - 10;
        } else {
          degrees = 10 - degrees;
        }

        if (degrees != 0 && degrees != 10)
          thumb_text = DELNIIT_NUMBERS[degrees - 1].key;
        else if (track_type == TrackType.lightness && degrees == 0) thumb_text = '✴';
      }

      return CustomMultiChildLayout(
        delegate: _SliderLayout(),
        children: <Widget>[
          LayoutId(
            id: _SliderLayout.track,
            child: CustomPaint(
              painter: _TrackPainter(
                colour_model: colour_model,
                track_type: track_type,
                colour: colour,
                discrete: discrete,
                theme: theme,
              ),
            ),
          ),
          LayoutId(
            id: _SliderLayout.thumb,
            child: Transform.translate(
              offset: Offset(thumb_offset, 0.0),
              child: CustomPaint(
                painter: _ThumbPainter(
                  theme: theme,
                  colour: colour.colour,
                  text: thumb_text,
                ),
              ),
            ),
          ),
          LayoutId(
            id: _SliderLayout.gesture_container,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints box) {
                RenderBox? render_box = context.findRenderObject() as RenderBox?;
                return GestureDetector(
                  onPanDown: (DragDownDetails details) => render_box != null ? slide_event(render_box, box, details.globalPosition) : null,
                  onPanUpdate: (DragUpdateDetails details) => render_box != null ? slide_event(render_box, box, details.globalPosition) : null,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class SliderRow extends StatefulWidget {
  final String label;
  final String full_name;
  final ColorModel model;
  final TrackType track_type;
  final double value;
  final double maximum;
  final TypedColour colour;
  final TypedColour Function(double) colour_updater;
  final bool decimal;
  final double? track_width;

  const SliderRow({
    required this.label,
    required this.full_name,
    required this.model,
    required this.track_type,
    required this.value,
    required this.maximum,
    required this.colour,
    required this.colour_updater,
    this.decimal = true,
    this.track_width,
  });

  @override
  _SliderRowState createState() => _SliderRowState();
}

class _SliderRowState extends State<SliderRow> {
  static final FLOAT_REGEX = RegExp(r'^(\d+(\.\d{0,2})?)?$');
  static final INT_REGEX = RegExp(r'^\d*$');

  late TextEditingController controller;
  String? error_text;

  static String format_float(double float) {
    return float.toStringAsFixed(2);
  }

  static String format_int(double int) {
    return int.round().toString();
  }

  String? validate_float(String? text) {
    if (text == null) return "Invalid ${widget.full_name}";
    try {
      double value = double.parse(text);
      if (value < 0 || value > widget.maximum) return "${widget.full_name} not within range";
    } on FormatException catch (_) {
      return "Invalid ${widget.full_name}";
    }
    return null;
  }

  String? validate_int(String? text) {
    if (text == null) return "Invalid ${widget.full_name}";
    try {
      int value = int.parse(text);
      if (value < 0 || value > widget.maximum) return "${widget.full_name} not within range";
    } on FormatException catch (_) {
      return "Invalid ${widget.full_name}";
    }
    return null;
  }

  String? validate(String? text) {
    if (widget.decimal)
      return validate_float(text);
    else
      return validate_int(text);
  }

  String format_value(double value) {
    return widget.decimal ? format_float(value) : format_int(value);
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: format_value(widget.value));
    error_text = null;
  }

  @override
  void didUpdateWidget(covariant SliderRow oldWidget) {
    String processed_text = controller.text;
    try {
      processed_text = format_value(double.parse(controller.text));
    } catch (_) {}
    if (oldWidget.value != widget.value && format_value(widget.value) != processed_text) {
      controller.text = format_value(widget.value);
      error_text = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);
    double width = MediaQuery.of(context).size.width;
    double track_width = widget.track_width ?? clampDouble(500, width * 0.3, (width - 100) * 0.9);

    return Column(
      children: [
        Row(
          children: [
            Text(widget.label, style: theme.textTheme.subtitle1),
            SizedBox(
              child: ColourPickerSlider(
                colour_model: widget.model,
                track_type: widget.track_type,
                maximum: widget.maximum,
                value: widget.value,
                colour: widget.colour,
                on_change: (v) => context.read<ColourCubit>().update_colour(widget.colour_updater(v)),
              ),
              width: track_width,
              height: 50,
            ),
            SizedBox(
              child: TextFormField(
                onChanged: (v) {
                  setState(() {
                    error_text = validate(v);
                  });
                  if (error_text == null) context.read<ColourCubit>().update_colour(widget.colour_updater(double.parse(v)));
                },
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  RegexInputFormatter(widget.decimal ? FLOAT_REGEX : INT_REGEX),
                ],
                validator: validate,
                decoration: InputDecoration(
                  isDense: true,
                  errorText: error_text,
                  errorStyle: const TextStyle(color: Colors.transparent, height: 0.01),
                ),
                textAlign: TextAlign.center,
              ),
              width: 34,
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        if (error_text != null)
          Text(
            error_text!,
            style: TextStyle(color: theme.errorColor),
          ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class DelniitSliderRow extends StatelessWidget {
  final TrackType track_type;
  final double value;
  final TypedColour colour;
  final HSLColor Function(double) colour_updater;
  final int steps;
  final double? track_width;
  final String? left;
  final String? right;

  const DelniitSliderRow({required this.track_type, required this.value, required this.colour, required this.colour_updater, this.track_width, this.steps = 10, this.left, this.right});

  @override
  Widget build(BuildContext context) {
    TextStyle delniit_style = TextStyle(
      fontFamily: constants.DELNIIT_FONT,
      fontSize: 18,
      fontWeight: colour.colour.brightness == Brightness.light ? FontWeight.bold : FontWeight.normal,
    );
    Widget left_widget = Text(left ?? ' ', style: delniit_style);
    if (left == null) left_widget = HideKeepSpace(child: left_widget);
    Widget right_widget = Text(right ?? ' ', style: delniit_style);
    if (right == null) right_widget = HideKeepSpace(child: right_widget);

    return Row(
      children: [
        left_widget,
        SizedBox(
          child: ColourPickerSlider(
            colour_model: ColorModel.hsl,
            track_type: track_type,
            maximum: 1,
            value: value,
            colour: colour,
            on_change: (v) => context.read<ColourCubit>().update_colour(HSLType(colour_updater(v))),
            discrete: true,
            steps: steps,
            show_cornai: true,
          ),
          width: track_width,
          height: 50,
        ),
        right_widget,
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}

double get_hue_angle(double hue) {
  int hue_ind = -1;
  for (int i = 0; i < DELNIIT_HUE_STOPS.length; i++) {
    if (hue < DELNIIT_HUE_STOPS[i] || i == DELNIIT_HUE_STOPS.length - 1) {
      hue_ind = i - 1;
      break;
    }
  }

  double angle_per_hue = 360 / (DELNIIT_HUE_STOPS.length - 1);
  double angle = angle_per_hue * hue_ind;
  if (hue_ind < DELNIIT_HUE_STOPS.length - 1) {
    double start_hue = DELNIIT_HUE_STOPS[hue_ind];
    double between_hues = DELNIIT_HUE_STOPS[hue_ind + 1] - start_hue;
    angle += ((hue - start_hue) / between_hues) * angle_per_hue;
  }
  return angle;
}

class _HueRingPainter extends CustomPainter {
  static List<double> get_hue_stops() {
    List<double> hue_stops = [];
    for (int i = 0; i < DELNIIT_HUE_STOPS.length - 1; i++) {
      double start_hue = DELNIIT_HUE_STOPS[i];
      double step = (DELNIIT_HUE_STOPS[i + 1] - start_hue) / 10;
      for (int c = 0; c < 10; c++) {
        hue_stops.add(start_hue + step * c);
      }
    }
    return hue_stops;
  }

  static final List<double> HUE_STOPS = get_hue_stops();

  const _HueRingPainter(this.hsl, {required this.theme, this.thickness = 10});

  final HSLColor hsl;
  final ThemeData theme;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;
    Offset centre = Offset(size.width / 2, size.height / 2);
    double radius = size.width <= size.height ? size.width / 2 : size.height / 2;
    double total_size = (radius + thickness / 2) * 2;
    Offset corner_offset = Offset(-thickness / 2, -thickness / 2);

    canvas.saveLayer(Rect.largest, Paint());
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(corner_offset.dx, corner_offset.dy, total_size, total_size),
        Radius.circular(total_size),
      ),
    );
    paint_transparency_grid(canvas: canvas, total_size: Size(total_size, total_size), offset: corner_offset, grid_size: Size(thickness / 1.5, thickness / 1.5));
    canvas.drawCircle(
        centre,
        radius - thickness / 2,
        Paint()
          ..blendMode = BlendMode.dstOut
          ..style = PaintingStyle.fill);
    canvas.restore();

    final List<Color> colors = DELNIIT_HUE_STOPS.map((hue) => hsl.withHue(hue).alt).toList();
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = SweepGradientPainter(colors: colors, colorSpace: ColorSpace.hsl).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness,
    );

    canvas.drawCircle(
      centre,
      radius + thickness / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = theme.dividerColor
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      centre,
      radius - thickness / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = theme.dividerColor
        ..strokeWidth = 1,
    );

    String? thumb_label;
    double angle_per_stop = 2 * pi / HUE_STOPS.length;
    for (int i = 0; i < HUE_STOPS.length; i++) {
      double hue = HUE_STOPS[i];
      bool current_hue;
      if (i == 0)
        current_hue = hsl.hue < angle_per_stop / 2 || hsl.hue > 360 - angle_per_stop / 2;
      else
        current_hue = hue > hsl.hue - angle_per_stop / 2 && hue < hsl.hue + angle_per_stop / 2;

      Color colour = hsl.withHue(hue).alt;
      Offset offset = Offset(
        centre.dx + radius * cos(angle_per_stop * i),
        centre.dy + radius * sin(angle_per_stop * i),
      );

      if (i % 10 == 0) {
        String label = DELNIIT_COLOURS[i ~/ 10].key;
        if (current_hue)
          thumb_label = label;
        else
          paint_slider_label(canvas: canvas, offset: offset, colour: colour, text: label);
      } else {
        if (current_hue) {
          int degrees = i % 10;
          if (degrees > 5) degrees = 10 - degrees;
          thumb_label = DELNIIT_NUMBERS[degrees - 1].key;
        } else
          paint_slider_tick(canvas: canvas, offset: offset, colour: colour);
      }
    }

    double angle = get_hue_angle(hsl.hue);
    final Offset offset = Offset(
      centre.dx + radius * cos((angle * pi / 180)),
      centre.dy + radius * sin((angle * pi / 180)),
    );
    paint_thumb(
      canvas: canvas,
      theme: theme,
      radius: AREA_THUMB_RADIUS,
      colour: hsl.alt,
      centre: offset,
    );

    if (thumb_label != null) paint_slider_thumb_label(canvas: canvas, offset: offset, colour: hsl.alt, text: thumb_label);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DelniitHueSlider extends StatelessWidget {
  final HSLColor colour;
  final ValueChanged<HSLColor> on_change;
  final double thickness;

  const DelniitHueSlider(
    this.colour,
    this.on_change, {
    Key? key,
    this.thickness = 10,
  }) : super(key: key);

  void _handle_gesture(Offset position, BuildContext context, double height, double width) {
    RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    Offset local_offset = box.globalToLocal(position);
    double horizontal = local_offset.dx.clamp(0.0, width);
    double vertical = local_offset.dy.clamp(0.0, height);

    Offset centre = Offset(width / 2, height / 2);
    double radius = width <= height ? width / 2 : height / 2;
    double dist = sqrt(pow(horizontal - centre.dx, 2) + pow(vertical - centre.dy, 2));
    double angle_fraction = (atan2(vertical - centre.dy, horizontal - centre.dx) / pi) / 2;
    angle_fraction = angle_fraction - angle_fraction.floor();
    int total_hues = DELNIIT_HUE_STOPS.length - 1;
    int hue_ind = (angle_fraction * total_hues).floor();
    int steps = (((angle_fraction * total_hues) - hue_ind) * 10).round();
    double base_hue = DELNIIT_HUE_STOPS[hue_ind];
    double hue = base_hue;
    if (hue_ind < DELNIIT_HUE_STOPS.length - 1) hue += (DELNIIT_HUE_STOPS[hue_ind + 1] - base_hue) * (steps / 10);
    if (dist > radius - thickness * 3 && dist < radius + thickness * 3) on_change(colour.withHue(hue));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);

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
          child: CustomPaint(
            painter: _HueRingPainter(colour, theme: theme, thickness: thickness),
          ),
        );
      },
    );
  }
}
