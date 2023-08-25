import '../utils/utils.dart';
import 'annotation.dart';

class PointAnnotation extends Annotation {
  PointAnnotation({
    required Time time,
    required super.text,
  }) : super(start: time, end: time);

  Time get time => start;

  set time(Time value) {
    super.start = value;
    super.end = value;
  }

  set start(Time v) =>
      throw UnsupportedError("[PointAnnotation]: use time instead of start.");

  set end(Time v) =>
      throw UnsupportedError("[PointAnnotation]: use time instead of end.");

  @override
  bool operator ==(Object other) {
    if (other is! PointAnnotation) {
      return false;
    }
    return super == other;
  }

  @override
  int get hashCode => Object.hash(start, end, text);

  @override
  PointAnnotation clone() {
    return PointAnnotation(
      time: this.time,
      text: '$text',
    );
  }
}
