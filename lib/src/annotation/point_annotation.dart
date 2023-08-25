import 'annotation.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable;

@jsonSerializable
class PointAnnotation extends Annotation {
  PointAnnotation({
    required double time,
    required super.text,
  }) : super(start: time, end: time);

  double get time => start;

  set time(double value) {
    super.start = value;
    super.end = value;
  }

  set start(double v) =>
      throw UnsupportedError("[PointAnnotation]: use time instead of start.");

  set end(double v) =>
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
