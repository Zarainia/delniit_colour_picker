import 'package:flutter/material.dart';

import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/constants.dart' as constants;
import 'package:colour_picker/util/theme.dart';

void paint_transparency_grid({required Canvas canvas, required Size total_size, required Size grid_size, Offset offset = const Offset(0, 0)}) {
  Paint black = Paint()..color = const Color(0xffcccccc);
  Paint white = Paint()..color = Colors.white;
  List.generate((total_size.height / grid_size.height).ceil(), (int y) {
    List.generate((total_size.width / grid_size.width).ceil(), (int x) {
      canvas.drawRect(
        (Offset(grid_size.width * x, grid_size.height * y) + offset) & grid_size,
        (x + y) % 2 != 0 ? white : black,
      );
    });
  });
}

void paint_thumb({required Canvas canvas, required ThemeData theme, required double radius, Color? colour, Offset centre = const Offset(0, 0)}) {
  Offset offset = centre - Offset(radius, radius);

  canvas.drawShadow(
    Path()..addOval(Rect.fromCircle(center: centre, radius: radius)),
    theme.shadowColor,
    6,
    true,
  );
  canvas.saveLayer(Rect.largest, Paint());
  canvas.clipRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, radius * 2, radius * 2),
      Radius.circular(radius),
    ),
  );
  paint_transparency_grid(canvas: canvas, total_size: Size(radius * 2, radius * 2), grid_size: Size(radius / 2, radius / 2), offset: offset);
  canvas.restore();
  Color colour_on_background = theme.canvasColor;
  canvas.drawCircle(
    centre,
    radius,
    Paint()
      ..color = Color.lerp(colour_on_background, colour_on_background.contrasting_colour, colour_on_background.brightness == Brightness.dark ? 0.4 : 0.3)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
  );
  if (colour != null) {
    canvas.drawCircle(
      centre,
      radius * 0.9,
      Paint()
        ..color = colour
        ..style = PaintingStyle.fill,
    );
  }
}

void paint_colour_text(
    {required Canvas canvas, required Offset offset, required Color text_colour, required Brightness shadow_brightness, required String text, double font_size = 18, bool shadow = true}) {
  Shadow text_shadow = Shadow(blurRadius: 3, color: shadow_brightness == Brightness.dark ? Colors.black : Colors.white);

  TextPainter text_painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: constants.DELNIIT_FONT,
        fontSize: font_size,
        color: text_colour,
        shadows: shadow ? List.generate(shadow_brightness == Brightness.light ? 2 : 1, (_) => text_shadow) : null,
        fontWeight: shadow_brightness == Brightness.light ? FontWeight.bold : FontWeight.normal,
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  text_painter.layout();
  Offset text_offset = offset -
      Offset(
            text_painter.width,
            text_painter.height,
          ) /
          2;
  text_painter.paint(canvas, text_offset);
}

void paint_slider_tick({required Canvas canvas, required Offset offset, required Color colour, double width = 2, bool highlighted = false, double intensity = 0}) {
  Color colour_on_background = get_colour_on_background(colour);
  Brightness brightness = colour_on_background.brightness;
  Color contrasting_colour = colour_on_background.contrasting_colour;

  if (highlighted)
    intensity = 1;
  else
    intensity *= brightness == Brightness.dark ? 0.7 : 0.5;
  double dimming = brightness == Brightness.dark ? 0.55 : 0.75;
  dimming *= (1 - intensity);

  canvas.drawCircle(
      offset,
      highlighted ? width * 1.5 : width,
      Paint()
        ..color = Color.lerp(contrasting_colour, null, dimming)!
        ..style = PaintingStyle.fill);
}

void paint_slider_label({required Canvas canvas, required Offset offset, required Color colour, required String text}) {
  Color colour_on_background = get_colour_on_background(colour);
  Brightness brightness = colour_on_background.brightness;
  Color contrasting_colour = colour_on_background.contrasting_colour;

  paint_colour_text(
    canvas: canvas,
    offset: offset,
    text_colour: contrasting_colour,
    shadow_brightness: brightness,
    text: text,
  );
}

void paint_slider_thumb_label({required Canvas canvas, required Offset offset, required Color colour, required String text}) {
  Color colour_on_background = get_colour_on_background(colour);
  Brightness brightness = colour_on_background.brightness;
  Color contrasting_colour = colour_on_background.contrasting_colour;

  paint_colour_text(
    canvas: canvas,
    offset: offset,
    text_colour: contrasting_colour,
    shadow_brightness: brightness,
    text: text,
    font_size: 14,
    shadow: false,
  );
}

class BackgroundGridPainter extends CustomPainter {
  final Size grid_size;

  BackgroundGridPainter({this.grid_size = const Size(20, 20)});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.largest, Paint());
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    paint_transparency_grid(canvas: canvas, total_size: size, grid_size: grid_size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
