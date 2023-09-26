import 'package:flutter_textgrid/src/io/text_grid_serializer_interface.dart';
import 'package:flutter_textgrid/src/text_grid.dart';

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
    final textGrid = TextGrid();

    if (lines[4].split(' ')[1] != '<exists>') {
      throw TextGridIOException(
        message: "Invalid TextGrid format.",
      );
    }

    int index = 7;

    while (index < lines.length) {
      final numObj = int.parse(_getAttrVal(lines[index + 5]));

      final tierClass = _getAttrVal(lines[index + 1]);
      switch (tierClass.trim()) {
        case '"IntervalTier"':
          textGrid.addTier(
            _readIntervalTier(
              lines.sublist(index, index + 6 + (numObj * 4)),
            ),
          );
          index += 6 + (numObj * 4);
          break;
        case '"TextTier"':
          textGrid.addTier(
            _readPointTier(
              lines.sublist(
                index,
                index + 6 + (numObj * 3),
              ),
            ),
          );
          index += 6 + (numObj * 3);
          break;
        default:
          throw TextGridIOException(message: 'Unknown tier type: $tierClass');
      }
    }

    return textGrid;
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

  String _getAttrVal(String x) {
    return x.split(' = ')[1];
  }

  PointTier _readPointTier(List<String> lines) {
    final name = _deescapeString(_getAttrVal(_nameWithoutQuotes(lines[2])));
    final startTime = Time(num.parse(_getAttrVal(lines[3])).toDouble());
    final endTime = Time(num.parse(_getAttrVal(lines[4])).toDouble());

    final pt = PointTier(name: name, startTime: startTime, endTime: endTime);

    var i = 7;

    while (i < lines.length) {
      final text = _nameWithoutQuotes(_getAttrVal(lines[i + 1]));
      pt.addAnnotation(
        PointAnnotation(
          time: Time(num.parse(_getAttrVal(lines[i])).toDouble()),
          text: text,
        ),
      );

      i += 3;
    }

    return pt;
  }

  IntervalTier _readIntervalTier(List<String> lines) {
    // name without quotes
    final name = _deescapeString(_getAttrVal(_nameWithoutQuotes(lines[2])));
    final startTime = Time(num.parse(_getAttrVal(lines[3])).toDouble());
    final endTime = Time(num.parse(_getAttrVal(lines[4])).toDouble());

    final it = IntervalTier(name: name, startTime: startTime, endTime: endTime);

    var i = 7;

    while (i < lines.length) {
      final text = _nameWithoutQuotes(_getAttrVal(lines[i + 2].trim()));
      it.addAnnotation(
        IntervalAnnotation(
          startTime: Time(num.parse(_getAttrVal(lines[i])).toDouble()),
          endTime: Time(num.parse(_getAttrVal(lines[i + 1])).toDouble()),
          text: _deescapeString(text),
        ),
      );

      i += 4;
    }

    return it;
  }

  String _nameWithoutQuotes(String text) {
    return text.replaceAll('"', '');
  }

  String _deescapeString(String text) {
    return text.replaceAll('""', '"');
  }
}
