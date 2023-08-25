import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable;
import 'package:flutter_textgrid/src/cloneable_interface.dart';

@jsonSerializable
abstract class Annotation implements ICloneable<Annotation> {
  double start;

  double end;

  String text;

  Annotation({
    required this.start,
    required this.end,
    required this.text,
  });

  @override
  bool operator ==(Object other) {
    if (other is! Annotation) {
      return false;
    }
    return start == other.start && end == other.end && text == other.text;
  }

  @override
  int get hashCode => Object.hash(start, end, text);
}

extension AnnotationsX on List<Annotation> {
  List<Annotation> deepClone() {
    final List<Annotation> annotations = List.empty(growable: true);
    for (final a in this) {
      annotations.add(a.clone());
    }
    return annotations;
  }
}
