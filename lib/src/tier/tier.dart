import 'package:bisection/extension.dart';
import 'package:collection/collection.dart';
import 'package:flutter_textgrid/src/annotation/annotation.dart';
import 'package:flutter_textgrid/src/cloneable_interface.dart';
import 'package:flutter_textgrid/src/io/text_grid_io_exception.dart';

import '../utils/utils.dart';

enum TierType {
  point(name: "PointTier"),
  interval(name: "IntervalTier");

  const TierType({required this.name});

  final String name;
}

enum AddAnnotationError { overlap }

abstract class Tier implements ICloneable<Tier> {
  late List<Annotation> annotations;

  Time _start;
  Time _end;

  String name;

  TierType tierType;

  Time get start {
    if (annotations.isNotEmpty) {
      return Time.min(annotations.first.start, _start);
    }
    return _start;
  }

  set start(Time time) {
    if (annotations.isNotEmpty && time > annotations.first.start) {
      throw TextGridIOException(
          message:
              "Start time cannot be set to a value greater than first annotation starts");
    }
    _start = time;
  }

  Time get end {
    if (annotations.isNotEmpty) {
      return Time.max(annotations.last.end, _end);
    }
    return _end;
  }

  set end(Time time) {
    if (annotations.isNotEmpty && time < annotations.last.end) {
      throw TextGridIOException(
          message:
              "End time cannot be set to a value less than last annotation ends");
    }
    _end = time;
  }

  Tier({
    required this.tierType,
    required this.name,
    Time start = Time.zero,
    Time end = Time.zero,
    List<Annotation>? annotations,
  })  : _start = start,
        _end = end {
    this.annotations = List.empty(growable: true);
    if (annotations != null) {
      this.addAnnotations(annotations);
    }
  }

  Result<void, AddAnnotationError> addAnnotation(Annotation annotation) {
    if (annotations.isEmpty || annotation.start >= annotations.last.end) {
      annotations.add(annotation);
    } else {
      final overlapping = getAnnotationsBetweenTimepoints(
        startTime: annotation.start,
        endTime: annotation.end,
        leftOverlap: true,
        rightOverlap: true,
      );

      if (overlapping.isEmpty) {
        final startTimepoints = getStartTimepoints().toList();
        final position = startTimepoints.bisectLeft(annotation.start.value);
        annotations.insert(position, annotation);
      } else {
        return Result.error(AddAnnotationError.overlap);
      }
    }

    return Result.ok(null);
  }

  void addAnnotations(Iterable<Annotation> annotations) {
    for (final annotation in annotations) {
      addAnnotation(annotation);
    }
  }

  List<Annotation> getAnnotationsBetweenTimepoints({
    required Time startTime,
    required Time endTime,
    required bool leftOverlap,
    required bool rightOverlap,
  }) {
    final (low, high) = _getAnnotationIndexRangeBetweenTimepoints(
      startTime: startTime,
      endTime: endTime,
      leftOverlap: leftOverlap,
      rightOverlap: rightOverlap,
    );

    return annotations.sublist(low, high);
  }

  (int low, int high) _getAnnotationIndexRangeBetweenTimepoints({
    required Time startTime,
    required Time endTime,
    required bool leftOverlap,
    required bool rightOverlap,
  }) {
    final List<double> startTimepoints = getStartTimepoints().toList();
    final List<double> endTimepoints = getEndTimepoints().toList();

    int lowIndex, highIndex;

    if (leftOverlap) {
      lowIndex = endTimepoints.bisectRight(startTime.value);
    } else {
      lowIndex = startTimepoints.bisectLeft(startTime.value);
    }

    if (rightOverlap) {
      highIndex = startTimepoints.bisectLeft(endTime.value);
    } else {
      highIndex = endTimepoints.bisectRight(endTime.value);
    }

    return (lowIndex, highIndex);
  }

  Iterable<double> getStartTimepoints() =>
      annotations.map((e) => e.start.value);
  Iterable<double> getEndTimepoints() => annotations.map((e) => e.end.value);

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
