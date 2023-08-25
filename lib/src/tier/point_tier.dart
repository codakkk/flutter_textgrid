import '../tier.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart'
    show jsonSerializable, Json;

@jsonSerializable
@Json(discriminatorValue: TierType.point)
class PointTier extends Tier {
  PointTier({
    required super.name,
    super.start = -1,
    super.end = -1,
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
}
