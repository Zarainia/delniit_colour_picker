import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/cubits/colour_cubit.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/widgets/misc.dart';

class HexPicker extends StatelessWidget {
  static final RegExp HEX_REGEX = RegExp(r"^[\da-fA-F]{0,8}$");

  final TypedColour curr_colour;
  final String hex;

  HexPicker({required this.curr_colour}) : hex = curr_colour.to_hex().hex;

  @override
  Widget build(BuildContext context) {
    return PlainInput(
      value: hex.toUpperCase(),
      on_change: (hex) => context.read<ColourCubit>().update_colour(HexType(hex)),
      validator: (val) {
        try {
          colour_from_hex(val ?? "");
        } catch (_) {
          return "Invalid hex format";
        }
        return null;
      },
      formatters: [RegexInputFormatter(HEX_REGEX), UpperCaseTextFormatter()],
      prefix_icon: Icon(Icons.tag),
      style: TextStyle(fontSize: 18),
      capitalization: TextCapitalization.characters,
    );
  }
}
