import 'package:collection/collection.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart'
    show Json, jsonSerializable;
import 'package:flutter_textgrid/src/annotation/annotation.dart';
import 'package:flutter_textgrid/src/cloneable_interface.dart';

@jsonSerializable
enum TierType { point, interval }

@jsonSerializable
@Json(discriminatorProperty: 'tierType')
abstract class Tier implements ICloneable<Tier> {
  late List<Annotation> annotations;

  double start;

  double end;

  String name;

  TierType tierType;

  Tier({
    required this.tierType,
    required this.name,
    this.start = -1,
    this.end = -1,
    List<Annotation>? annotations,
  }) : assert(
          start != -1 && end != -1 || start == -1 && end == -1,
          "When passing start or end, both values must be set.",
        ) {
    this.annotations = annotations ?? List.empty(growable: true);
  }

  void addAnnotation(Annotation annotation) {
    annotations.add(annotation);

    // Adapt the end time if adding the annotation implies a change
    if (end < annotation.end) {
      end = annotation.end;
    }
  }

  void addAnnotations(Iterable<Annotation> annotations) {
    Annotation? endIt;

    for (final annotation in annotations) {
      endIt = annotation;
      this.annotations.add(annotation);
    }

    if (endIt != null && end < endIt.end) {
      end = endIt.end;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! Tier) {
      return false;
    }
    return start == other.start &&
        end == other.end &&
        name == other.name &&
        const ListEquality().equals(annotations, other.annotations);
  }

  @override
  int get hashCode => Object.hash(start, end, name, annotations);
}

extension TiersX on List<Tier> {
  List<Tier> deepClone() {
    final List<Tier> tiers = List.empty(growable: true);
    for (final a in this) {
      tiers.add(a.clone());
    }
    return tiers;
  }
}
