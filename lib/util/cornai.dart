import 'package:flutter/material.dart';

import 'package:delniit_utils/delniit_utils.dart';
import 'package:intersperse/intersperse.dart';
import 'package:zarainia_utils/zarainia_utils.dart';

const List<double> DELNIIT_HUE_STOPS = [0, 30, 60, 120, 240, 270, 360];
const List<MapEntry<String, String>> DELNIIT_COLOURS = [
  MapEntry('W', 'wax'),
  MapEntry('N', 'ɴıмм'),
  MapEntry('F', 'ſaɴ'),
  MapEntry('V', 'víss'),
  MapEntry('Ф', 'ɸıʟ'),
  MapEntry('Ԍ', 'ʒeaçeɴ'),
  MapEntry('W', 'wax'),
];
const List<MapEntry<String, String>> DELNIIT_NUMBERS = [
  MapEntry('ꟷ', 'cé'),
  MapEntry('ǁ', 'ᴧacc'),
  MapEntry('Ξ', 'мoг'),
  MapEntry('Ø', 'ƃıг'),
  MapEntry('Ꝋ', 'ɴıг'),
  MapEntry('∇', 'veм'),
  MapEntry('‡', 'ʒeaʟ'),
  MapEntry('U', 'тoгм'),
  MapEntry('◊', 'ᴧíve'),
];
const MapEntry<String, String> DELNIIT_GREY = MapEntry('H', 'нeгɴ');
const MapEntry<String, String> DELNIIT_BLACK = MapEntry('C', 'cэcse');
const MapEntry<String, String> DELNIIT_WHITE = MapEntry('Δ', 'ᴧaſe');
const MapEntry<String, String> DELNIIT_TRANSPARENT = MapEntry('Z', 'zaʒea');
const List<MapEntry<String, String>> ADDITIONAL_DELNIIT_COLOUR_WORDS = [DELNIIT_GREY, DELNIIT_BLACK, DELNIIT_WHITE, DELNIIT_TRANSPARENT];

const MapEntry<String, String> DELNIIT_CLA = MapEntry('c', 'cʟa');

final Map<String, int> DELNIIT_NUMBER_CONVERSIONS = {for (int i = 0; i < DELNIIT_NUMBERS.length; i++) DELNIIT_NUMBERS[i].key: i + 1};
final Map<String, int> DELNIIT_NUMBER_WORD_CONVERSIONS = {for (int i = 0; i < DELNIIT_NUMBERS.length; i++) DELNIIT_NUMBERS[i].value: i + 1};
final Map<String, String> DELNIIT_COLOUR_WORD_CONVERSIONS = Map.fromEntries(DELNIIT_COLOURS + ADDITIONAL_DELNIIT_COLOUR_WORDS).invert();
final Map<String, int> DELNIIT_COLOUR_CONVERSIONS = {for (int i = 0; i < DELNIIT_COLOURS.length - 1; i++) DELNIIT_COLOURS[i].key: i};
final Set<String> ADDITIONAL_DELNIIT_COLOUR_WORD_CHARS = ADDITIONAL_DELNIIT_COLOUR_WORDS.map((e) => e.key).toSet();

enum DelniitColourType {
  cornai('coгɴaı'),
  cla('cʟa'),
  dakk_fleppi('ᴧacc ſʟeччı'),
  ce_flepp('cé ſʟeчч');

  final String display_name;

  const DelniitColourType(this.display_name);
}

int _get_degrees(double value, {double start = 0, double end = 1, int total = 10}) {
  double step = (end - start).abs() / total;
  if (end > start) {
    end -= step / 2;
    start += step / 2;
    if (value < start)
      return 0;
    else if (value > end) return 10;
  } else {
    end += step / 2;
    start -= step / 2;
    if (value > start)
      return 0;
    else if (value < end) return 10;
  }
  return (value - start).abs() ~/ step + 1;
}

String _get_text(MapEntry<String, String> name, {bool full_word = false}) => full_word ? name.value : name.key;

String _get_degree_text(int n, {bool full_word = false}) {
  if (!full_word)
    return DELNIIT_NUMBERS[n - 1].key;
  else
    return DELNIIT_NUMBERS[n - 1].value + ' ' + (n == 1 ? 'coгɴa' : 'coгɴaı');
}

List<String> _construct_degree_text({
  required List<String> existing,
  required int degrees,
  MapEntry<String, String>? a,
  required MapEntry<String, String> b,
  DelniitColourType type = DelniitColourType.cornai,
  bool full_words = false,
}) {
  List<String> a_text = a == null ? existing : [_get_text(a, full_word: full_words)];
  List<String> b_text = [_get_text(b, full_word: full_words)];
  if ((type == DelniitColourType.cornai && degrees == 0) ||
      (type == DelniitColourType.cla && degrees < 3) ||
      (type == DelniitColourType.dakk_fleppi && degrees < 2) ||
      (type == DelniitColourType.ce_flepp && degrees < 6)) {
    return a_text;
  } else if ((type == DelniitColourType.cornai && degrees == 10) ||
      (type == DelniitColourType.cla && degrees > 7) ||
      (type == DelniitColourType.dakk_fleppi && degrees > 8) ||
      type == DelniitColourType.ce_flepp)
    return b_text;
  else {
    switch (type) {
      case DelniitColourType.cornai:
        return a_text + [_get_degree_text(degrees, full_word: full_words)] + b_text;
      case DelniitColourType.cla:
        return a_text + [full_words ? 'cʟa' : 'c'] + b_text;
      case DelniitColourType.dakk_fleppi:
        return a_text + b_text;
      case DelniitColourType.ce_flepp:
        throw UnimplementedError();
    }
  }
}

String colour_to_delniit_string(HSLColor colour, {DelniitColourType type = DelniitColourType.cornai, bool full_words = false}) {
  double hue = colour.hue;
  int hue_ind = -1;
  for (int i = 0; i < DELNIIT_HUE_STOPS.length; i++) {
    if (hue < DELNIIT_HUE_STOPS[i] || i == DELNIIT_HUE_STOPS.length - 1) {
      hue_ind = i - 1;
      break;
    }
  }

  double step = (DELNIIT_HUE_STOPS[hue_ind + 1] - DELNIIT_HUE_STOPS[hue_ind]) / 10;
  bool primary = hue_ind % 2 == 0;
  double midpoint = DELNIIT_HUE_STOPS[hue_ind] + (primary ? 5.5 : 4.5) * step;
  int hue_start_ind, hue_end_ind;
  if (hue >= midpoint) {
    hue_start_ind = hue_ind + 1;
    hue_end_ind = hue_ind;
  } else {
    hue_start_ind = hue_ind;
    hue_end_ind = hue_ind + 1;
  }

  int hue_degrees = _get_degrees(hue, start: DELNIIT_HUE_STOPS[hue_start_ind], end: DELNIIT_HUE_STOPS[hue_end_ind]);
  List<String> parts = _construct_degree_text(
    existing: [],
    degrees: hue_degrees,
    a: DELNIIT_COLOURS[hue_start_ind],
    b: DELNIIT_COLOURS[hue_end_ind],
    type: type,
    full_words: full_words,
  );

  int sat_degrees = _get_degrees(colour.saturation, start: 1, end: 0);
  parts = _construct_degree_text(
    existing: parts,
    degrees: sat_degrees,
    b: DELNIIT_GREY,
    type: type,
    full_words: full_words,
  );

  bool light = colour.lightness > 0.5;
  int lightness_degrees = _get_degrees(colour.lightness, start: 0.5, end: light ? 1 : 0);
  parts = _construct_degree_text(
    existing: parts,
    degrees: lightness_degrees,
    b: light ? DELNIIT_WHITE : DELNIIT_BLACK,
    type: type,
    full_words: full_words,
  );

  int alpha_degrees = _get_degrees(colour.alpha, start: 1, end: 0);
  parts = _construct_degree_text(
    existing: parts,
    degrees: alpha_degrees,
    b: DELNIIT_TRANSPARENT,
    type: type,
    full_words: full_words,
  );

  return parts.join(full_words ? ' ' : '');
}

class DelniitColourParseException extends FormatException {}

bool _is_colour(String char) => DELNIIT_COLOUR_CONVERSIONS.containsKey(char);

HSLColor _parse_alpha(double? hue, double? sat, double? lightness, List<dynamic> words) {
  double? alpha;

  if (words.isEmpty)
    alpha = 1;
  else {
    if (words[0] == DELNIIT_TRANSPARENT.key) {
      words.removeAt(0);
      alpha = 0;
    } else if (words.length > 1 && words[0] is int && words[1] == DELNIIT_TRANSPARENT.key) {
      if (hue == null && sat == null && lightness == null) throw DelniitColourParseException();

      double step = 1 / 10;
      alpha = 1 - step * (words.removeAt(0) as int);
      words.removeAt(0);
    }
  }

  if (alpha == null || words.isNotEmpty) throw DelniitColourParseException();

  return HSLColor.fromAHSL(alpha, hue ?? 0, sat ?? 1, lightness ?? 0.5);
}

HSLColor _parse_lightness(double? hue, double? sat, List<dynamic> words) {
  if (words.isEmpty) return HSLColor.fromAHSL(1, hue ?? 0, sat ?? 1, 0.5);

  double? lightness;
  if (words[0] == DELNIIT_WHITE.key) {
    words.removeAt(0);
    lightness = 1;
  } else if (words[0] == DELNIIT_BLACK.key) {
    words.removeAt(0);
    lightness = 0;
  } else if (words.length > 1 && words[0] is int && (words[1] == DELNIIT_WHITE.key || words[1] == DELNIIT_BLACK.key)) {
    if (hue == null && sat == null) throw DelniitColourParseException();

    double step = 0.5 / 10;
    int n = words.removeAt(0);
    int dir = words.removeAt(0) == DELNIIT_WHITE.key ? 1 : -1;
    lightness = 0.5 + step * dir * n;
  }

  return _parse_alpha(hue, sat, lightness, words);
}

HSLColor _parse_saturation(double? hue, List<dynamic> words) {
  if (words.isEmpty) return HSLColor.fromAHSL(1, hue!, 1, 0.5);

  double? sat;
  if (words[0] == DELNIIT_GREY.key) {
    words.removeAt(0);
    sat = 0;
  } else if (words.length > 1 && words[0] is int && words[1] == DELNIIT_GREY.key) {
    if (hue == null) throw DelniitColourParseException();

    double step = 1 / 10;
    sat = 1 - step * (words.removeAt(0) as int);
    words.removeAt(0);
  }

  return _parse_lightness(hue, sat, words);
}

HSLColor _parse_hue(List<dynamic> words) {
  if (words.isEmpty) throw DelniitColourParseException();

  int? hue1;
  int? hue_degrees;
  int? hue2;

  double? hue;

  if (_is_colour(words.first)) {
    hue1 = DELNIIT_COLOUR_CONVERSIONS[words.removeAt(0)];
    if (words.length > 1 && words[0] is int && _is_colour(words[1])) {
      hue_degrees = words.removeAt(0);
      hue2 = DELNIIT_COLOUR_CONVERSIONS[words.removeAt(0)];
    }
  }
  if (hue1 != null && hue_degrees != null && hue2 != null) {
    if (hue1 == 0 && hue2 == 5) hue1 = 6;
    if (hue2 == 0 && hue1 == 5) hue2 = 6;

    if ((hue2 - hue1).abs() != 1) throw DelniitColourParseException();

    double point1 = DELNIIT_HUE_STOPS[hue1];
    double point2 = DELNIIT_HUE_STOPS[hue2];
    double step = (point2 - point1) / 10;
    hue = point1 + step * hue_degrees;
  } else if (hue1 != null) hue = DELNIIT_HUE_STOPS[hue1];

  return _parse_saturation(hue, words);
}

HSLColor parse_delniit_colour(String string) {
  List<String> split_string = string.splitWhitespace();
  List<dynamic> words = [];

  int i = 0;
  bool has_degrees = false;
  bool has_cla = false;
  bool has_full_words = false;
  bool has_shorthand = false;
  while (i < split_string.length) {
    String word = split_string[i].trim();
    String lower_word = delniit_lower(word);
    if (DELNIIT_COLOUR_WORD_CONVERSIONS.containsKey(lower_word)) {
      words.add(DELNIIT_COLOUR_WORD_CONVERSIONS[lower_word]!);
      has_full_words = true;
    } else if (DELNIIT_NUMBER_WORD_CONVERSIONS.containsKey(lower_word)) {
      int n = DELNIIT_NUMBER_WORD_CONVERSIONS[lower_word]!;
      if (i + 1 < split_string.length && split_string[i + 1] == (n == 1 ? 'coгɴa' : 'coгɴaı')) {
        words.add(n);
        i++;
      } else {
        throw DelniitColourParseException();
      }
      has_degrees = true;
      has_full_words = true;
    } else if (lower_word == DELNIIT_CLA.value) {
      words.add(5);
      has_cla = true;
      has_full_words = true;
    } else {
      List<String> characters = delniit_split(word);
      for (int j = 0; j < characters.length; j++) {
        String char = characters[j];
        if (_is_colour(char) || ADDITIONAL_DELNIIT_COLOUR_WORD_CHARS.contains(char))
          words.add(char);
        else if (DELNIIT_NUMBER_CONVERSIONS.containsKey(char)) {
          int n = DELNIIT_NUMBER_CONVERSIONS[char]!;
          words.add(n);
          if (j == characters.length - 1 && i + 1 < split_string.length && split_string[i + 1] == (n == 1 ? 'coгɴa' : 'coгɴaı')) i++;
          has_degrees = true;
        } else if (char == DELNIIT_CLA.key) {
          words.add(5);
          has_cla = true;
        } else
          throw DelniitColourParseException();
      }
      if (characters.length > 1) has_shorthand = true;
    }
    i++;
  }

  bool has_two_words = false;
  for (int i = 0; i < words.length - 1; i++) {
    if (words[i] is! int && words[i + 1] is! int) {
      has_two_words = true;
      break;
    }
  }

  if (has_degrees.toInt() + has_cla.toInt() + has_two_words.toInt() > 1 || (has_full_words && has_shorthand)) throw DelniitColourParseException();

  if (has_two_words) words = intersperse(5, words).toList();

  return _parse_hue(words);
}
