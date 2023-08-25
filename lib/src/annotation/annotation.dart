import 'package:flutter_textgrid/src/cloneable_interface.dart';

import '../utils/utils.dart';

abstract class Annotation implements ICloneable<Annotation> {
  Time start;

  Time end;

  String text;

  Time get duration => end - start;

  Annotation({
    required this.start,
    required this.end,
    required this.text,
  }) : assert(start <= end, "Start time after end time.");

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
