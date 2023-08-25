import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable;

@jsonSerializable
abstract class Annotation {
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
