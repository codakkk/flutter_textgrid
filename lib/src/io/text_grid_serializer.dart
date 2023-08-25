import 'dart:html';

import 'package:flutter_textgrid/src/io/text_grid_io_exception.dart';
import 'package:flutter_textgrid/src/text_grid.dart';
import 'package:flutter_textgrid/src/text_grid_type.dart';
import 'package:flutter_textgrid/src/tier/tier.dart';

import '../annotation/annotation.dart';
import '../annotation/interval_annotation.dart';
import '../annotation/point_annotation.dart';
import '../tier/interval_tier.dart';
import '../tier/point_tier.dart';

class TextGridSerializer {
  static const String defaultLineSeparator = "\n";

  static const String lineSeparatorPattern = "[\\n\\r]+";

  static final RegExp propertyPattern =
      RegExp(r'^[ \t]*([a-zA-Z0-9]+)[ \t]*=[ \t]*\"?([^"]*)\"?');

  static final RegExp tierPattern =
      RegExp("^[ \t]*item[ \t]*\\[[0-9]+\\][ \t]*:.*");

  static final RegExp intervalsPattern =
      RegExp("^[ \t]*intervals[ \t]*:[ \t]*size[ \t]*=[ \t]*([0-9]+)");

  static final RegExp intervalItemPattern =
      RegExp("^[ \t]*intervals[ \t]*\\[[0-9]+\\][ \t]*:.*");

  static final RegExp pointsPattern =
      RegExp("^[ \t]*points[ \t]*:[ \t]*size[ \t]*=[ \t]*([0-9]+)");

  static final RegExp pointItemPattern =
      RegExp("^[ \t]*points[ \t]*\\[[0-9]+\\][ \t]*:.*");

  TextGrid fromString(String tgString) {
    final lines = tgString.split(RegExp(lineSeparatorPattern)).toList();

    var tmpLine = lines.removeAt(0);

    if (tmpLine != 'File type = "ooTextFile"') {
      throw TextGridIOException(
        message: "Header is not correctly formatted ($tmpLine)",
      );
    }

    tmpLine = lines.removeAt(0);
    if (tmpLine != 'Object class = "TextGrid"') {
      throw TextGridIOException(
        message: "Header is not correctly formatted ($tmpLine)",
      );
    }

    if (!lines[0].startsWith('xmin')) {
      throw TextGridIOException(
        message: 'Short format not supported yet or invalid line ${lines[0]}',
      );
    }

    // Extract START
    var tmp = lines.removeAt(0);

    var match = propertyPattern.firstMatch(tmp);
    final xminString = match?.group(2);
    if (xminString == null) {
      throw TextGridIOException(
        message: 'start line is not correctly formatted',
      );
    }

    final double xmin = double.parse(xminString);

    // Extract END

    tmp = lines.removeAt(0);
    match = propertyPattern.firstMatch(tmp);
    final xmaxString = match?.group(2);
    if (xmaxString == null) {
      throw TextGridIOException(
        message: 'end line is not correctly formatted',
      );
    }

    final double xmax = double.parse(xmaxString);

    // Why this line? Ask the java creator lol
    lines.removeAt(0);

    // Number of tiers
    tmp = lines.removeAt(0);
    match = propertyPattern.firstMatch(tmp);
    final noOfTiersString = match?.group(2);
    if (noOfTiersString == null) {
      throw TextGridIOException(
        message: 'nb_tiers line is not correctly formatted',
      );
    }

    final nbTiers = int.parse(noOfTiersString.trim());

    lines.removeAt(0);

    final tiers = _readLongTextGrid(lines);

    if (tiers.length != nbTiers) {
      throw TextGridIOException(
        message:
            'Inconsistency between the number of tiers parsed (${tiers.length}) and the expected number of tiers ($nbTiers)',
      );
    }

    return TextGrid(start: xmin, end: xmax, tiers: tiers);
  }

  List<Tier> _readLongTextGrid(List<String> lines) {
    late Tier tier;
    final List<Tier> tiers = List.empty(growable: true);

    var match = tierPattern.firstMatch(lines[0]);
    while (match != null) {
      lines.removeAt(0);

      final propertyMatch = propertyPattern.firstMatch(lines.removeAt(0));
      if (propertyMatch != null && propertyMatch.group(1) == 'class') {
        final type = propertyMatch.group(2);

        tier = switch (type) {
          'IntervalTier' => _readLongIntervalTier(lines),
          'TextTier' => _readLongPointTier(lines),
          _ =>
            throw TextGridIOException(message: 'Unknown class of tier: $type'),
        };
      } else {
        throw TextGridIOException(
            message: "Tier's class should be defined here.");
      }

      tiers.add(tier);

      if (lines.isEmpty) {
        break;
      }

      match = tierPattern.firstMatch(lines[0]);
    }

    return tiers;
  }

  Tier _readLongIntervalTier(List<String> lines) {
    double start = -1;
    double end = -1;
    late String name;

    // Tier header
    RegExpMatch? match = intervalsPattern.firstMatch(lines[0]);
    while (match == null) {
      final line = lines[0];

      final propertyMatch = propertyPattern.firstMatch(line);
      if (propertyMatch != null) {
        final groupOne = propertyMatch.group(1);
        final groupTwo = propertyMatch.group(2);

        if (groupOne == 'name') {
          name = groupTwo!;
        } else if (groupOne == 'xmin') {
          start = double.parse(groupTwo!);
        } else if (groupOne == 'xmax') {
          end = double.parse(groupTwo!);
        } else {
          throw TextGridIOException(
            message: 'Property $groupOne is unknown for a tier',
          );
        }
      } else {
        final intervalMatch = intervalsPattern.firstMatch(line);
        if (intervalMatch == null) {
          throw TextGridIOException(
            message: 'A property is expected here: $line',
          );
        }
      }

      lines.removeAt(0);
      match = intervalsPattern.firstMatch(lines[0]);
    }

    final List<Annotation> annotations = List.empty(growable: true);

    lines.removeAt(0);
    match = intervalItemPattern.firstMatch(lines[0]);
    while (match != null) {
      lines.removeAt(0);
      double startAn = -1;
      double endAn = -1;
      late String text;

      match = propertyPattern.firstMatch(lines[0]);
      while (match != null) {
        lines.removeAt(0);

        final firstGroup = match.group(1);
        final secondGroup = match.group(2);

        if (firstGroup == 'text') {
          text = secondGroup!;
        } else if (firstGroup == 'xmin') {
          startAn = double.parse(secondGroup!);
        } else if (firstGroup == 'xmax') {
          endAn = double.parse(secondGroup!);
        } else {
          throw TextGridIOException(
            message: 'Property $firstGroup is unknown for an annotation',
          );
        }

        if (lines.isEmpty) {
          break;
        }

        match = propertyPattern.firstMatch(lines[0]);
      }

      Annotation annotation = IntervalAnnotation(
        start: startAn,
        end: endAn,
        text: text,
      );
      annotations.add(annotation);

      if (lines.isEmpty) {
        break;
      }

      match = intervalItemPattern.firstMatch(lines[0]);
    }

    return IntervalTier(
      name: name,
      start: start,
      end: end,
      annotations: annotations,
    );
  }

  Tier _readLongPointTier(List<String> lines) {
    double start = -1;
    double end = -1;
    late String name;

    // Tier header
    RegExpMatch? match = pointsPattern.firstMatch(lines[0]);
    while (match == null) {
      String line = lines[0];

      match = propertyPattern.firstMatch(line);
      if (match != null) {
        final groupOne = match.group(1);
        final groupTwo = match.group(2);

        if (groupOne == 'name') {
          name = groupTwo!;
        } else if (groupOne == 'xmin') {
          start = double.parse(groupTwo!);
        } else if (groupOne == 'xmax') {
          end = double.parse(groupTwo!);
        } else {
          throw TextGridIOException(
            message: 'Property $groupOne is unknown for a tier',
          );
        }
      } else {
        match = pointsPattern.firstMatch(line);
        if (match == null) {
          throw TextGridIOException(
              message: 'A property is expected here: $line');
        }
      }

      lines.removeAt(0);
      match = pointsPattern.firstMatch(lines[0]);
    }

    final List<Annotation> annotations = List.empty(growable: true);
    lines.removeAt(0);
    match = pointItemPattern.firstMatch(lines[0]);
    while (match != null) {
      lines.removeAt(0);
      double time = -1;
      late String text;

      match = propertyPattern.firstMatch(lines[0]);
      while (match != null) {
        lines.removeAt(0);

        final groupOne = match.group(1);
        final groupTwo = match.group(2);

        if (groupOne == 'mark') {
          text = groupTwo!;
        } else if (groupOne == 'number') {
          time = double.parse(groupTwo!);
        } else {
          throw TextGridIOException(
            message: 'Property $groupOne is unknown for an annotation',
          );
        }

        if (lines.isEmpty) {
          break;
        }

        match = propertyPattern.firstMatch(lines[0]);
      }

      Annotation annotation = PointAnnotation(time: time, text: text);
      annotations.add(annotation);

      if (lines.isEmpty) {
        break;
      }

      match = pointItemPattern.firstMatch(lines[0]);
    }

    return PointTier(
      name: name,
      start: start,
      end: end,
      annotations: annotations,
    );
  }

  String textGridToString(
    TextGrid tgt, {
    TextGridType type = TextGridType.long,
  }) =>
      switch (type) {
        TextGridType.long => _textGridToLongString(tgt),
        TextGridType.short => _textGridToShortString(tgt)
      };

  String _textGridToShortString(TextGrid textGrid) {
    final buffer = StringBuffer();

    final result = [
      'File type = "ooTextFile"',
      'Object class = "TextGrid"',
      '',
      '${textGrid.start}',
      '${textGrid.end}',
      '<exists>',
      '${textGrid.tiers.length}',
    ];

    buffer.write('File type = "ooTextFile"$defaultLineSeparator');

    return result.join(defaultLineSeparator);
    /*
    def export_to_short_textgrid(textgrid):
    '''Convert a TextGrid object into a string of Praat short TextGrid format.'''
    result = ['File type = "ooTextFile"',
              'Object class = "TextGrid"',
              '',
              str(textgrid.start_time),
              str(textgrid.end_time),
              '<exists>',
              str(len(textgrid))]
    textgrid_corrected = correct_start_end_times_and_fill_gaps(textgrid)
    for tier in textgrid_corrected:
        result += ['"' + tier.tier_type() + '"',
                   '"' + escape_text(tier.name) + '"',
                   str(tier.start_time), str(tier.end_time), str(len(tier))]
        if isinstance(tier, IntervalTier):
            result += [u'{0}\n{1}\n"{2}"'.format(obj.start_time, obj.end_time, escape_text(obj.text))
                       for obj in tier]
        elif isinstance(tier, PointTier):
            result += [u'{0}\n"{1}"'.format(obj.time, escape_text(obj.text))
                       for obj in tier]
        else:
            raise Exception('Unknown tier type: {0}'.format(tier.name))
    return '\n'.join(result)
    
     */
  }

  /*
    Correct the start/end times of all tiers and fill gaps.
    Returns a copy of a textgrid, where empty gaps between intervals
    are filled with empty intervals and where start and end times are
    unified with the start and end times of the whole textgrid.
  */
  TextGrid correctStartEndTimesAndFillGaps(TextGrid tg) {
    final tgCopy = tg.clone();
    for (int i = 0; i < tgCopy.tiers.length; ++i) {
      final tier = tgCopy.tiers[i];
      if (tier is IntervalTier) {
        final tierCorrected = tier.copyWithGapsFilled(
          startTime: tg.start,
          endTime: tg.end,
        );
        tgCopy.tiers[i] = tierCorrected;
      }
    }

    return tgCopy;
  }

  String _textGridToLongString(TextGrid tgt) {
    final str_tgt = StringBuffer();
    str_tgt.write("File type = \"ooTextFile\"$defaultLineSeparator");
    str_tgt.write("Object class = \"TextGrid\"$defaultLineSeparator");
    str_tgt.write(defaultLineSeparator);
    str_tgt.write('xmin = ${tgt.start}$defaultLineSeparator');
    str_tgt.write('xmax = ${tgt.end}$defaultLineSeparator');
    str_tgt.write('tiers? <exists>$defaultLineSeparator');

    // Tier export
    final tiers = tgt.tiers;
    str_tgt.write('size = ${tiers.length}$defaultLineSeparator');

    str_tgt.write('item []:$defaultLineSeparator');
    for (int t = 0; t < tiers.length; t++) {
      // Get the current tier
      Tier tier = tiers[t];

      str_tgt.write('\titem [${t + 1}]:$defaultLineSeparator');

      if (tier is IntervalTier) {
        str_tgt.write('\t\tclass = "IntervalTier"$defaultLineSeparator');
      } else if (tier is PointTier) {
        str_tgt.write('\t\tclass = "TextTier"$defaultLineSeparator');
      } else {
        throw TextGridIOException(
            message: '${tier.runtimeType} serialization is not supported');
      }

      str_tgt.write('\t\tname = "${tier.name}"$defaultLineSeparator');
      str_tgt.write('\t\txmin = ${tier.start}$defaultLineSeparator');
      str_tgt.write('\t\txmax = ${tier.end}$defaultLineSeparator');

      final annotations = tier.annotations;

      if (tier is IntervalTier) {
        str_tgt.write(
            "\t\tintervals: size = ${annotations.length}$defaultLineSeparator");
      } else if (tier is PointTier) {
        str_tgt.write(
            "\t\tpoints: size = ${annotations.length}$defaultLineSeparator");
      }

      // Each annotations
      if (tier is IntervalTier) {
        for (int a = 0; a < annotations.length; a++) {
          IntervalAnnotation an = annotations[a] as IntervalAnnotation;
          str_tgt.write('\t\t\tintervals [${a + 1}]$defaultLineSeparator');
          str_tgt.write('\t\t\t\txmin = ${an.start}$defaultLineSeparator');
          str_tgt.write('\t\t\t\txmax = ${an.end}$defaultLineSeparator');
          str_tgt.write('\t\t\t\ttext = "${an.text}"$defaultLineSeparator');
        }
      } else if (tier is PointTier) {
        //
        for (int a = 0; a < annotations.length; a++) {
          PointAnnotation an = annotations[a] as PointAnnotation;
          str_tgt.write('\t\t\tpoints [${a + 1}]:$defaultLineSeparator');
          str_tgt.write('\t\t\t\tnumber = ${an.time}$defaultLineSeparator');
          str_tgt.write('\t\t\t\tmark = "${an.text}$defaultLineSeparator');
        }
      }
    }

    return str_tgt.toString();
  }
}
