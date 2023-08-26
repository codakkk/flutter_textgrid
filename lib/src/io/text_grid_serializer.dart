import 'dart:io';

import 'package:flutter_textgrid/src/io/text_grid_io_exception.dart';
import 'package:flutter_textgrid/src/io/text_grid_long_serializer.dart';
import 'package:flutter_textgrid/src/io/text_grid_short_serializer.dart';
import 'package:flutter_textgrid/src/text_grid.dart';
import 'package:flutter_textgrid/src/text_grid_type.dart';

import 'patterns.dart';

class TextGridSerializer {
  final _longSerializer = TextGridLongSerializer();
  final _shortSerializer = TextGridShortSerializer();

  Future<TextGrid> fromPath(String path) => fromFile(File(path));

  Future<TextGrid> fromFile(File file) async {
    final data = await file.readAsString();

    return fromString(data);
  }

  TextGrid fromString(String tgString) {
    final lines =
        tgString.split(RegExp(Patterns.lineSeparatorPattern)).where((row) {
      final r = row.trim();
      if (r.isEmpty || r == '"') {
        return false;
      }
      return true;
    }).toList();

    // check for header

    if (!_validateHeader(lines)) {
      throw TextGridIOException(
        message: "Invalid TextGrid Header:\n${lines[0]}\n${lines[1]}",
      );
    }

    if (lines[2].startsWith('xmin')) {
      // long
      return _longSerializer.deserialize(lines);
    } else {
      // short
      return _shortSerializer.deserialize(lines);
    }
  }

  bool _validateHeader(List<String> lines) {
    if ((lines[0] != 'File type = "ooTextFile"' ||
            lines[1] != 'Object class = "TextGrid"') &&
        (lines[0] != 'File type = "ooTextFile short"' ||
            lines[1] != '"TextGrid"')) {
      return false;
    }
    return true;
  }

  String textGridToString(
    TextGrid tgt, {
    TextGridType type = TextGridType.long,
  }) =>
      switch (type) {
        TextGridType.long => _longSerializer.toText(tgt),
        TextGridType.short => _shortSerializer.toText(tgt)
      };
}
