import 'package:flutter_textgrid/src/io/text_grid_serializer_interface.dart';
import 'package:flutter_textgrid/src/text_grid.dart';

import '../annotation/interval_annotation.dart';
import '../annotation/point_annotation.dart';
import '../tier/interval_tier.dart';
import '../tier/point_tier.dart';
import '../utils/time.dart';
import 'patterns.dart';
import 'text_grid_io_exception.dart';

class TextGridShortSerializer implements ITextGridSerializer {
  @override
  TextGrid deserialize(List<String> lines) {
    final tg = TextGrid();

    if (lines[4] != '<exists>') {
      throw TextGridIOException(
        message: "Invalid TextGrid format. Not short for sure",
      );
    }

    int index = 6;

    while (index < lines.length) {
      final numObj = int.parse(lines[index + 4]);

      if (lines[index] == '"IntervalTier"') {
        tg.addTier(
          _readShortIntervalTier(
            lines.sublist(index, index + 5 + numObj * 3),
          ),
        );

        index += 5 + (numObj * 3);
      } else if (lines[index] == '"TextTier"') {
        tg.addTier(
          _readShortPointTier(
            lines.sublist(index, index + 5 + numObj * 2),
          ),
        );

        index += 5 + (numObj * 2);
      } else {
        throw TextGridIOException(message: 'Unknown tier type');
      }
    }

    return tg;
  }

  @override
  String toText(TextGrid textGrid) {
    final result = [
      'File type = "ooTextFile"',
      'Object class = "TextGrid"',
      '',
      '${textGrid.startTime}',
      '${textGrid.endTime}',
      '<exists>',
      '${textGrid.tiers.length}',
    ];

    final correctedTextGrid = _correctStartEndTimesAndFillGaps(textGrid);
    for (final tier in correctedTextGrid.tiers) {
      result.add('"${tier.tierType.name}"');
      result.add('"${RegExp.escape(tier.tierType.name)}"');
      result.add(
          '${tier.startTime}, ${tier.endTime}, ${tier.annotations.length}');

      if (tier is IntervalTier) {
        for (final annotation in tier.annotations) {
          result.add(
            '${annotation.startTime}${Patterns.defaultLineSeparator}${annotation.endTime}${Patterns.defaultLineSeparator}${RegExp.escape(annotation.text)}',
          );
        }
      } else if (tier is PointTier) {
        for (final annotation in tier.annotations) {
          result.add('${(annotation as PointAnnotation).time}');
          result.add(RegExp.escape(annotation.text));
        }
      } else {
        throw TextGridIOException(message: "Invalid Tier");
      }
    }
    return result.join(Patterns.defaultLineSeparator);
  }

  /*
    Correct the start/end times of all tiers and fill gaps.
    Returns a copy of a textgrid, where empty gaps between intervals
    are filled with empty intervals and where start and end times are
    unified with the start and end times of the whole textgrid.
  */
  TextGrid _correctStartEndTimesAndFillGaps(TextGrid tg) {
    final tgCopy = tg.clone();
    for (int i = 0; i < tgCopy.tiers.length; ++i) {
      final tier = tgCopy.tiers[i];
      if (tier is IntervalTier) {
        final tierCorrected = tier.copyWithGapsFilled(
          startTime: tg.startTime.value,
          endTime: tg.endTime.value,
        );
        tgCopy.tiers[i] = tierCorrected;
      }
    }

    return tgCopy;
  }

  IntervalTier _readShortIntervalTier(List<String> lines) {
    // name without quotes
    final name = _deescapeString(lines[1].replaceAll('"', ''));
    final startTime = Time(num.parse(lines[2]).toDouble());
    final endTime = Time(num.parse(lines[3]).toDouble());
    final it = IntervalTier(
      startTime: startTime,
      endTime: endTime,
      name: name,
    );

    int i = 5;

    while (i < lines.length) {
      final text = lines[i + 2].replaceAll('"', '');
      if (text.trim().isNotEmpty) {
        it.addAnnotation(
          IntervalAnnotation(
            startTime: Time(num.parse(lines[i]).toDouble()),
            endTime: Time(num.parse(lines[i + 1]).toDouble()),
            text: _deescapeString(text),
          ),
        );
      }

      i += 3;
    }

    return it;
  }

  PointTier _readShortPointTier(List<String> lines) {
    // name without quotes
    final name = _deescapeString(lines[1].replaceAll('"', ''));
    final startTime = Time(num.parse(lines[2]).toDouble());
    final endTime = Time(num.parse(lines[3]).toDouble());
    final pt = PointTier(
      startTime: startTime,
      endTime: endTime,
      name: name,
    );

    int i = 5;

    while (i < lines.length) {
      final text = lines[i + 1].replaceAll('"', '');
      pt.addAnnotation(
        PointAnnotation(
          time: Time(num.parse(lines[i]).toDouble()),
          text: _deescapeString(text),
        ),
      );
      i += 2;
    }

    return pt;
  }

  String _deescapeString(String text) {
    return text.replaceAll('""', '"');
  }
}
