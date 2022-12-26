import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:measured_size/measured_size.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

import 'package:colour_picker/cubits/colour_cubit.dart';
import 'package:colour_picker/cubits/settings_cubit.dart';
import 'package:colour_picker/displays/display.dart';
import 'package:colour_picker/objects/colour_type.dart';
import 'package:colour_picker/pickers/picker.dart';
import 'package:colour_picker/util/theme.dart';
import 'package:colour_picker/widgets/appbar_selectors.dart';
import 'package:colour_picker/widgets/painters.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(create: (_) => ColourCubit()),
      ],
      child: BlocBuilder<ColourCubit, TypedColour>(builder: (context, colour) {
        ThemeData theme = generate_colour_based_theme(colour.colour);
        return ZarainiaThemeProvider(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: MyHomePage(colour: colour),
          ),
          theme: "dark",
          background_colour: theme.canvasColor,
          primary_colour: theme.colorScheme.primary,
          secondary_colour: theme.colorScheme.secondary,
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final TypedColour colour;

  const MyHomePage({required this.colour});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double appbar_selectors_height = 0;

  @override
  Widget build(BuildContext context) {
    Size device_size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: MeasuredSize(
          child: const AppBarSelectors(),
          onChange: (size) {
            setState(() {
              appbar_selectors_height = size.height;
            });
          },
        ),
        toolbarHeight: max(appbar_selectors_height, kToolbarHeight),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              child: Container(
                child: CustomPaint(
                  painter: BackgroundGridPainter(),
                ),
                width: device_size.width,
              ),
            ),
            Container(
              child: Material(
                child: Column(
                  children: [
                    DisplayPage(colour: widget.colour),
                    PickerPage(colour: widget.colour),
                  ],
                ),
                color: Colors.transparent,
              ),
              width: device_size.width,
              constraints: BoxConstraints(minHeight: device_size.height),
              color: widget.colour.colour,
              padding: const EdgeInsets.only(bottom: 50),
            ),
          ],
        ),
      ),
    );
  }
}
