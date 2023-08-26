import '../utils/utils.dart';
import 'annotation.dart';

class PointAnnotation extends Annotation {
  PointAnnotation({
    required Time time,
    required super.text,
  })  : _time = time,
        super(startTime: time, endTime: time);

  Time _time;

  Time get time => _time;

  set time(Time value) {
    _time = value;
  }

  @override
  Time get startTime => _time;

  @override
  set startTime(Time v) => time = v;

  @override
  Time get endTime => _time;

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
      time: this.time,
      text: '$text',
    );
  }
}
