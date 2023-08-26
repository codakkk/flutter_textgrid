import '../utils/utils.dart';
import 'annotation.dart';

class PointAnnotation extends Annotation {
  PointAnnotation({
    required this.time,
    required super.text,
  }) : super(startTime: time, endTime: time);

  Time time;

  @override
  Time get startTime => time;

  @override
  set startTime(Time v) => time = v;

  @override
  Time get endTime => time;

  @override
  set endTime(Time v) => time = v;

  @override
  bool operator ==(Object other) {
    if (other is! PointAnnotation) {
      return false;
    }
    return super == other;
  }

  @override
  int get hashCode => Object.hash(startTime, endTime, text);

  @override
  PointAnnotation clone() {
    return PointAnnotation(
      time: time,
      text: text,
    );
  }
}
