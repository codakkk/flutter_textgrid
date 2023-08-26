import 'package:flutter_textgrid/src/cloneable_interface.dart';

import '../utils/utils.dart';

abstract class Annotation implements ICloneable<Annotation> {
  Time _startTime;
  Time _endTime;

  String text;

  Time get startTime => _startTime;
  set startTime(Time time) {
    if (time > endTime) {
      throw ArgumentError.value(time, "time", "Start time after end time.");
    }

    _startTime = time;
  }

  Time get endTime => _endTime;
  set endTime(Time time) {
    if (time < startTime) {
      throw ArgumentError.value(time, "time", "End time before start time.");
    }
    _endTime = time;
  }

  Time get duration => endTime - startTime;

  Annotation({
    required Time startTime,
    required Time endTime,
    required this.text,
  })  : assert(startTime <= endTime, "Start time after end time."),
        _startTime = startTime,
        _endTime = endTime;

  @override
  bool operator ==(Object other) {
    if (other is! Annotation) {
      return false;
    }
    return startTime == other.startTime &&
        endTime == other.endTime &&
        text == other.text;
  }

  @override
  int get hashCode => Object.hash(startTime, endTime, text);
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
