import 'annotation.dart';

class IntervalAnnotation extends Annotation {
  IntervalAnnotation({
    required super.startTime,
    required super.endTime,
    required super.text,
  });

  @override
  bool operator ==(Object other) {
    if (other is! IntervalAnnotation) {
      return false;
    }
    return super == other;
  }

  @override
  int get hashCode => Object.hash(startTime, endTime, text);

  @override
  IntervalAnnotation clone() {
    return IntervalAnnotation(
      startTime: startTime,
      endTime: endTime,
      text: '$text',
    );
  }
}
