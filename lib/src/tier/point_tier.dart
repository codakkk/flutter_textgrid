import '../annotation/annotation.dart';
import '../utils/utils.dart';
import 'tier.dart';

class PointTier extends Tier {
  PointTier({
    required super.name,
    super.startTime = Time.zero,
    super.endTime = Time.zero,
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
        super.startTime,
        super.name,
        super.endTime,
        super.annotations,
      );

  @override
  PointTier clone() {
    return PointTier(
      name: '${this.name}',
      startTime: this.startTime,
      endTime: this.endTime,
      annotations: annotations.deepClone(),
    );
  }
}
