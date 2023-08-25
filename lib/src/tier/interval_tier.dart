import 'package:flutter_textgrid/src/annotation/interval_annotation.dart';

import '../annotation/annotation.dart';
import '../utils/utils.dart';
import 'tier.dart';

class IntervalTier extends Tier {
  IntervalTier({
    required super.name,
    super.start = Time.zero,
    super.end = Time.zero,
    super.annotations,
  }) : super(tierType: TierType.interval);

  IntervalTier copyWithGapsFilled({
    double? startTime,
    double? endTime,
    String emptyString = '',
  }) {
    final tierCopy = this.clone();

    if (startTime != null) {
      tierCopy.start = start;
    }

    if (endTime != null) {
      tierCopy.end = end;
    }

    // If no intervals exist, add one interval from start to end
    if (annotations.length == 0) {
      final empty = IntervalAnnotation(
        text: emptyString,
        start: start,
        end: end,
      );
      tierCopy.addAnnotation(empty);
    } else {
      // If necessary, add empty interval at start of tier
      if (annotations[0].start > tierCopy.start) {
        final empty = IntervalAnnotation(
          start: tierCopy.start,
          end: annotations[0].start,
          text: emptyString,
        );
        tierCopy.addAnnotation(empty);
      }

      // If necessary, add empty interval at end of tier
      if (annotations.last.end < tierCopy.end) {
        final empty = IntervalAnnotation(
          start: annotations.last.end,
          end: tierCopy.end,
          text: emptyString,
        );
        tierCopy.addAnnotation(empty);
      }

      // Insert empty intervals in between non-meeting intervals
      for (int i = 0; i < annotations.length; ++i) {
        final annotation = annotations[i];
        if (annotation.end >= annotations[i + 1].start) {
          continue;
        }

        final empty = IntervalAnnotation(
          start: annotation.end,
          end: annotation.start,
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
        super.start,
        super.name,
        super.end,
        super.annotations,
      );

  @override
  IntervalTier clone() {
    return IntervalTier(
      name: '${this.name}',
      start: this.start,
      end: this.end,
      annotations: annotations.deepClone(),
    );
  }
}
