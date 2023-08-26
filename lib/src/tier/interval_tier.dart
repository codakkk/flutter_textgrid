import 'package:flutter_textgrid/src/annotation/interval_annotation.dart';

import '../annotation/annotation.dart';
import '../utils/utils.dart';
import 'tier.dart';

class IntervalTier extends Tier {
  IntervalTier({
    required super.name,
    super.startTime = Time.zero,
    super.endTime = Time.zero,
    super.annotations,
  }) : super(tierType: TierType.interval);

  IntervalTier copyWithGapsFilled({
    double? startTime,
    double? endTime,
    String emptyString = '',
  }) {
    final tierCopy = clone();

    if (startTime != null) {
      tierCopy.startTime = startTime.toTime();
    }

    if (endTime != null) {
      tierCopy.endTime = endTime.toTime();
    }

    // If no intervals exist, add one interval from start to end
    if (annotations.isEmpty) {
      final empty = IntervalAnnotation(
        text: emptyString,
        startTime: this.startTime,
        endTime: this.endTime,
      );
      tierCopy.addAnnotation(empty);
    } else {
      // If necessary, add empty interval at start of tier
      if (annotations[0].startTime > tierCopy.startTime) {
        final empty = IntervalAnnotation(
          startTime: tierCopy.startTime,
          endTime: annotations[0].startTime,
          text: emptyString,
        );
        tierCopy.addAnnotation(empty);
      }

      // If necessary, add empty interval at end of tier
      if (annotations.last.endTime < tierCopy.endTime) {
        final empty = IntervalAnnotation(
          startTime: annotations.last.endTime,
          endTime: tierCopy.endTime,
          text: emptyString,
        );
        tierCopy.addAnnotation(empty);
      }

      // Insert empty intervals in between non-meeting intervals
      for (int i = 0; i < annotations.length; ++i) {
        final annotation = annotations[i];
        if (annotation.endTime >= annotations[i + 1].startTime) {
          continue;
        }

        final empty = IntervalAnnotation(
          startTime: annotation.endTime,
          endTime: annotation.startTime,
          text: emptyString,
        );
        tierCopy.addAnnotation(empty);
      }
    }
    return tierCopy;
  }

  @override
  bool operator ==(Object other) {
    if (other is! IntervalTier) {
      return false;
    }

    return super == other;
  }

  @override
  int get hashCode => Object.hash(
        super.startTime,
        super.name,
        super.endTime,
        super.annotations,
      );

  @override
  IntervalTier clone() {
    return IntervalTier(
      name: name,
      startTime: startTime,
      endTime: endTime,
      annotations: annotations.deepClone(),
    );
  }
}
