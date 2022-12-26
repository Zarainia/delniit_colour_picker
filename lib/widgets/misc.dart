import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/constants.dart' as constants;
import 'package:colour_picker/widgets/settings.dart';

class AlwaysWinPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  String get debugDescription => 'alwaysWin';
}

class PlainInput extends StatefulWidget {
  final String value;
  final Function(String) on_change;
  final String? Function(String?)? validator;
  final List<TextInputFormatter> formatters;
  final Widget? prefix;
  final Widget? prefix_icon;
  final TextStyle? style;
  final TextCapitalization capitalization;

  PlainInput({
    required this.value,
    required this.on_change,
    this.validator,
    this.formatters = const [],
    this.prefix,
    this.prefix_icon,
    this.style,
    this.capitalization = TextCapitalization.none,
  });

  @override
  _PlainInputState createState() => _PlainInputState();
}

class _PlainInputState extends State<PlainInput> {
  late TextEditingController controller;
  String? error_text;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant PlainInput oldWidget) {
    if (oldWidget.value != widget.value && widget.value != controller.text) {
      controller.text = widget.value;
      error_text = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);

    return Container(
      child: TextFormField(
        controller: controller,
        onChanged: (val) {
          if (widget.validator != null) {
            setState(() {
              error_text = widget.validator!(val);
            });
          }
          if (error_text == null) widget.on_change(val);
        },
        validator: widget.validator,
        decoration: TextFieldBorder(
          focused_colour: theme.colorScheme.onBackground,
          context: context,
          errorText: error_text,
          prefix: widget.prefix,
          prefixIcon: widget.prefix_icon,
        ),
        inputFormatters: widget.formatters,
        style: widget.style,
        textCapitalization: widget.capitalization,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 700),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class PlainDisplay extends StatelessWidget {
  final String value;
  final bool delniit;
  final Widget? settings_popover;

  const PlainDisplay({required this.value, this.delniit = false, this.settings_popover});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = get_themedata(context);
    double width = MediaQuery.of(context).size.width;
    double text_width = clampDouble(350, width * 0.35, width * 0.95);

    Widget? settings_button = settings_popover != null ? SettingsPopoverButton(content: settings_popover!) : null;
    Widget copy_button = IconButton(
      icon: const Icon(Icons.content_copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Copied to clipboard")));
      },
      constraints: const BoxConstraints(),
    );

    return Container(
      child: Row(
        children: [
          HideKeepSpace(child: copy_button),
          if (settings_button != null) HideKeepSpace(child: settings_button),
          const SizedBox(width: 10),
          Flexible(
            child: PaddinglessSelectableText(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: delniit ? constants.DELNIIT_FONT : null,
                fontSize: delniit ? theme.textTheme.headlineSmall!.fontSize! + 3 : theme.textTheme.headlineSmall!.fontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          if (settings_button != null) settings_button,
          copy_button,
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      width: text_width,
    );
  }
}

String format_comma_value_string({
  required List<num> values,
  List<bool> is_int = const [false, false, false, false],
}) {
  assert(values.length <= is_int.length);

  String result = "";
  for (int i = 0; i < values.length; i++) {
    String value;
    if (is_int[i])
      value = values[i].round().toString();
    else
      value = values[i].toStringAsFixed(2);
    result += value;
    if (i < values.length - 1) result += ", ";
  }

  return result;
}
