import '../annotation/annotation.dart';
import '../utils/utils.dart';
import 'tier.dart';

class PointTier extends Tier {
  PointTier({
    required super.name,
    super.start = Time.zero,
    super.end = Time.zero,
    super.annotations,
  }) : super(tierType: TierType.point);

  @override
  bool operator ==(Object other) {
    if (other is! PointTier) {
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
  PointTier clone() {
    return PointTier(
      name: '${this.name}',
      start: this.start,
      end: this.end,
      annotations: annotations.deepClone(),
    );
  }
}
