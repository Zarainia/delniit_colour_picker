import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:colour_picker/objects/colour_type.dart';

class ColourCubit extends Cubit<TypedColour> {
  ColourCubit() : super(DelniitType('Ф'));

  void update_colour(TypedColour colour) => emit(colour);
}
