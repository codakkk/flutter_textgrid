import 'package:flutter_textgrid/src/io/text_grid_serializer_interface.dart';
import 'package:flutter_textgrid/src/text_grid.dart';

import '../annotation/annotation.dart';
import '../annotation/interval_annotation.dart';
import '../annotation/point_annotation.dart';
import '../tier/interval_tier.dart';
import '../tier/point_tier.dart';
import '../tier/tier.dart';
import '../utils/utils.dart';
import 'patterns.dart';
import 'text_grid_io_exception.dart';

class TextGridLongSerializer implements ITextGridSerializer {
  @override
  TextGrid deserialize(List<String> lines) {
    lines.removeAt(0);
    lines.removeAt(0);

    // Extract START
    var tmp = lines.removeAt(0);

    var match = Patterns.propertyPattern.firstMatch(tmp);
    final xminString = match?.group(2);
    if (xminString == null) {
      throw TextGridIOException(
        message: 'start line is not correctly formatted',
      );
    }

    final double xmin = double.parse(xminString);

    // Extract END

    tmp = lines.removeAt(0);
    match = Patterns.propertyPattern.firstMatch(tmp);
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
    match = Patterns.propertyPattern.firstMatch(tmp);
    final noOfTiersString = match?.group(2);
    if (noOfTiersString == null) {
      throw TextGridIOException(
        message: 'nb_tiers line is not correctly formatted',
      );
    }

    final nbTiers = int.parse(noOfTiersString.trim());

    lines.removeAt(0);

    final tiers = _readLongTextGridTiers(lines);

    if (tiers.length != nbTiers) {
      throw TextGridIOException(
        message:
            'Inconsistency between the number of tiers parsed (${tiers.length}) and the expected number of tiers ($nbTiers)',
      );
    }

    return TextGrid(
      startTime: Time(xmin),
      endTime: Time(xmax),
      tiers: tiers,
    );
  }

  @override
  String toText(TextGrid tg) {
    final tiers = tg.tiers;
    final List<String> result = List.empty(growable: true);

    result.addAll(
      [
        "File type = \"ooTextFile\"",
        "Object class = \"TextGrid\"",
        Patterns.defaultLineSeparator,
        'xmin = ${tg.startTime}',
        'xmax = ${tg.endTime}',
        'tiers? <exists>',
        'size = ${tiers.length}',
        'item []:',
      ],
    );

    for (int t = 0; t < tiers.length; t++) {
      // Get the current tier
      Tier tier = tiers[t];

      result.addAll(
        [
          '\titem [${t + 1}]:',
          switch (tier) {
            IntervalTier() => '\t\tclass = "IntervalTier"',
            PointTier() => '\t\tclass = "TextTier"',
            _ => throw TextGridIOException(
                message: '${tier.runtimeType} serialization is not supported',
              )
          },
          '\t\tname = "${tier.name}"',
          '\t\txmin = ${tier.startTime}',
          '\t\txmax = ${tier.endTime}',
          switch (tier) {
            IntervalTier() =>
              '\t\tintervals: size = ${tier.annotations.length}',
            PointTier() => '\t\tpoints: size = ${tier.annotations.length}',
            _ => throw TextGridIOException(
                message: '${tier.runtimeType} serialization is not supported',
              )
          },
        ],
      );

      // Each annotations
      if (tier is IntervalTier) {
        for (int a = 0; a < tier.annotations.length; a++) {
          IntervalAnnotation an = tier.annotations[a] as IntervalAnnotation;
          result.addAll([
            '\t\t\tintervals [${a + 1}]',
            '\t\t\t\txmin = ${an.startTime}',
            '\t\t\t\txmax = ${an.endTime}',
            '\t\t\t\ttext = "${an.text}"',
          ]);
        }
      } else if (tier is PointTier) {
        for (int a = 0; a < tier.annotations.length; a++) {
          PointAnnotation an = tier.annotations[a] as PointAnnotation;
          result.addAll([
            '\t\t\tpoints [${a + 1}]:',
            '\t\t\t\tnumber = ${an.time}',
            '\t\t\t\tmark = "${an.text}',
          ]);
        }
      }
    }

    return result.join(Patterns.defaultLineSeparator);
  }

  List<Tier> _readLongTextGridTiers(List<String> lines) {
    late Tier tier;
    final List<Tier> tiers = List.empty(growable: true);

    var match = Patterns.tierPattern.firstMatch(lines[0]);
    while (match != null) {
      lines.removeAt(0);

      final propertyMatch =
          Patterns.propertyPattern.firstMatch(lines.removeAt(0));
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

      match = Patterns.tierPattern.firstMatch(lines[0]);
    }

    return tiers;
  }

  Tier _readLongIntervalTier(List<String> lines) {
    double start = -1;
    double end = -1;
    late String name;

    // Tier header
    RegExpMatch? match = Patterns.intervalsPattern.firstMatch(lines[0]);
    while (match == null) {
      final line = lines[0];

      final propertyMatch = Patterns.propertyPattern.firstMatch(line);
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
        final intervalMatch = Patterns.intervalsPattern.firstMatch(line);
        if (intervalMatch == null) {
          throw TextGridIOException(
            message: 'A property is expected here: $line',
          );
        }
      }

      lines.removeAt(0);
      match = Patterns.intervalsPattern.firstMatch(lines[0]);
    }

    final List<Annotation> annotations = List.empty(growable: true);

    lines.removeAt(0);
    match = Patterns.intervalItemPattern.firstMatch(lines[0]);
    while (match != null) {
      lines.removeAt(0);
      double startAn = -1;
      double endAn = -1;
      late String text;

      match = Patterns.propertyPattern.firstMatch(lines[0]);
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

        match = Patterns.propertyPattern.firstMatch(lines[0]);
      }

      Annotation annotation = IntervalAnnotation(
        startTime: startAn.toTime(),
        endTime: endAn.toTime(),
        text: text,
      );
      annotations.add(annotation);

      if (lines.isEmpty) {
        break;
      }

      match = Patterns.intervalItemPattern.firstMatch(lines[0]);
    }

    return IntervalTier(
      name: name,
      startTime: start.toTime(),
      endTime: end.toTime(),
      annotations: annotations,
    );
  }

  Tier _readLongPointTier(List<String> lines) {
    double start = -1;
    double end = -1;
    late String name;

    // Tier header
    RegExpMatch? match = Patterns.pointsPattern.firstMatch(lines[0]);
    while (match == null) {
      String line = lines[0];

      match = Patterns.propertyPattern.firstMatch(line);
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
        match = Patterns.pointsPattern.firstMatch(line);
        if (match == null) {
          throw TextGridIOException(
              message: 'A property is expected here: $line');
        }
      }

      lines.removeAt(0);
      match = Patterns.pointsPattern.firstMatch(lines[0]);
    }

    final List<Annotation> annotations = List.empty(growable: true);
    lines.removeAt(0);
    match = Patterns.pointItemPattern.firstMatch(lines[0]);
    while (match != null) {
      lines.removeAt(0);
      double time = -1;
      late String text;

      match = Patterns.propertyPattern.firstMatch(lines[0]);
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

        match = Patterns.propertyPattern.firstMatch(lines[0]);
      }

      Annotation annotation = PointAnnotation(time: time.toTime(), text: text);
      annotations.add(annotation);

      if (lines.isEmpty) {
        break;
      }

      match = Patterns.pointItemPattern.firstMatch(lines[0]);
    }

    return PointTier(
      name: name,
      startTime: start.toTime(),
      endTime: end.toTime(),
      annotations: annotations,
    );
  }
}
