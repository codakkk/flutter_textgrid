import 'annotation.dart';

class IntervalAnnotation extends Annotation {
  IntervalAnnotation({
    required super.start,
    required super.end,
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
  int get hashCode => Object.hash(start, end, text);

  @override
  IntervalAnnotation clone() {
    return IntervalAnnotation(
      start: start,
      end: end,
      text: '$text',
    );
  }
}
