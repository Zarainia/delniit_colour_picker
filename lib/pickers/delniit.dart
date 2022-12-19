import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/constants.dart' as constants;
import 'package:colour_picker/cubits/colour_cubit.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/util/cornai.dart';
import 'package:colour_picker/widgets/misc.dart';
import 'package:colour_picker/widgets/slider.dart';

class DelniitComboPicker extends StatelessWidget {
  static const double CENTRE_HEIGHT = 200;

  final TypedColour curr_colour;
  final HSLColor hsl;

  const DelniitComboPicker({required this.curr_colour, required this.hsl});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double size = clampDouble(600, width * 0.3, width * 0.9);
    double centre_width = sqrt(pow(size - 10, 2) - pow(CENTRE_HEIGHT, 2));
    double full_width = size - 40;
    double track_width = centre_width - 100;

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: DelniitHueSlider(hsl, (value) => context.read<ColourCubit>().update_colour(HSLType(value))),
          ),
          Positioned.fill(
            child: Align(
              child: Container(
                width: centre_width,
                height: CENTRE_HEIGHT,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Align(
              child: Container(
                width: full_width,
                height: CENTRE_HEIGHT / 3,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                DelniitSliderRow(
                  left: 'H',
                  right: '✴',
                  track_type: TrackType.saturationForHSL,
                  value: hsl.saturation,
                  colour: curr_colour,
                  colour_updater: (sat) => hsl.withSaturation(sat),
                  track_width: track_width,
                ),
                DelniitSliderRow(
                  left: 'C',
                  right: 'Δ',
                  track_type: TrackType.lightness,
                  value: hsl.lightness,
                  steps: 20,
                  colour: curr_colour,
                  colour_updater: (lightness) => hsl.withLightness(lightness),
                  track_width: size - 100,
                ),
                DelniitSliderRow(
                  left: 'Z',
                  right: '✴',
                  track_type: TrackType.alpha,
                  value: hsl.alpha,
                  colour: curr_colour,
                  colour_updater: (alpha) => hsl.withAlpha(alpha),
                  track_width: track_width,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          )
        ],
      ),
    );
  }
}

class DelniitPicker extends StatelessWidget {
  final TypedColour curr_colour;
  final HSLColor hsl;
  final String delniit;

  DelniitPicker({required this.curr_colour})
      : hsl = curr_colour.to_hsl().hsl,
        delniit = curr_colour.to_delniit().delniit;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);

    return Column(
      children: [
        PlainInput(
          value: delniit,
          on_change: (delniit) => context.read<ColourCubit>().update_colour(DelniitType(delniit)),
          validator: (val) {
            try {
              parse_delniit_colour(val ?? "");
            } on DelniitColourParseException catch (_) {
              return "Invalid Delniit format";
            }
            return null;
          },
          prefix: Padding(
            child: Text('Δ', style: TextStyle(fontSize: 22, fontFamily: constants.DELNIIT_FONT, height: 1, color: theme.iconTheme.color?.withOpacity(theme.iconTheme.opacity ?? 1))),
            padding: const EdgeInsets.only(right: 10),
          ),
          style: TextStyle(fontSize: 20, fontFamily: constants.DELNIIT_FONT),
        ),
        const SizedBox(height: 30),
        DelniitComboPicker(curr_colour: curr_colour, hsl: hsl),
      ],
    );
  }
}
