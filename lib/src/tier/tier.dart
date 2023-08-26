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

  Time _startTime;
  Time _endTime;

  String name;

  TierType tierType;

  Time get startTime {
    if (annotations.isNotEmpty) {
      return Time.min(annotations.first.startTime, _startTime);
    }
    return _startTime;
  }

  set startTime(Time time) {
    if (annotations.isNotEmpty && time > annotations.first.startTime) {
      throw TextGridIOException(
          message:
              "Start time cannot be set to a value greater than first annotation starts");
    }
    _startTime = time;
  }

  Time get endTime {
    if (annotations.isNotEmpty) {
      return Time.max(annotations.last.endTime, _endTime);
    }
    return _endTime;
  }

  set endTime(Time time) {
    if (annotations.isNotEmpty && time < annotations.last.endTime) {
      throw TextGridIOException(
          message:
              "End time cannot be set to a value less than last annotation ends");
    }
    _endTime = time;
  }

  Tier({
    required this.tierType,
    required this.name,
    Time startTime = Time.zero,
    Time endTime = Time.zero,
    List<Annotation>? annotations,
  })  : _startTime = startTime,
        _endTime = endTime {
    this.annotations = List.empty(growable: true);
    if (annotations != null) {
      addAnnotations(annotations);
    }
  }

  Result<void, AddAnnotationError> addAnnotation(Annotation annotation) {
    if (annotations.isEmpty ||
        annotation.startTime >= annotations.last.endTime) {
      annotations.add(annotation);
    } else {
      final overlapping = getAnnotationsBetweenTimepoints(
        startTime: annotation.startTime,
        endTime: annotation.endTime,
        leftOverlap: true,
        rightOverlap: true,
      );

      if (overlapping.isEmpty) {
        final startTimepoints = getStartTimepoints().toList();
        final position = startTimepoints.bisectLeft(annotation.startTime.value);
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
      annotations.map((e) => e.startTime.value);
  Iterable<double> getEndTimepoints() =>
      annotations.map((e) => e.endTime.value);

  @override
  bool operator ==(Object other) {
    if (other is! Tier) {
      return false;
    }
    return startTime == other.startTime &&
        endTime == other.endTime &&
        name == other.name &&
        const ListEquality().equals(annotations, other.annotations);
  }

  @override
  int get hashCode => Object.hash(startTime, endTime, name, annotations);
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
