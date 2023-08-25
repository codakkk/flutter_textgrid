import 'package:collection/collection.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart'
    show JsonMapper, jsonSerializable, JsonProperty;

import 'tier.dart';

@jsonSerializable
class TextGrid {
  @JsonProperty()
  double start;

  @JsonProperty()
  double end;

  @JsonProperty()
  late List<Tier> tiers;

  TextGrid({this.start = -1, this.end = -1, List<Tier>? tiers})
      : assert(
          start != -1 && end != -1 || start == -1 && end == -1,
          "When passing start or end, both values must be set.",
        ) {
    this.tiers = tiers ?? List.empty(growable: true);
  }

  void addTierAt(Tier tier, int position) {
    if (position < 0) {
      tiers.add(tier);
    } else {
      tiers.insert(position, tier);
    }
  }

  void addTier(Tier tier) {
    tiers.add(tier);
  }

  void addTiers(Iterable<Tier> tiers) {
    this.tiers.addAll(tiers);
  }

  void deleteTierByName(String name) {
    final pos = tiers.indexWhere((element) => element.name == name);

    if (pos >= 0) {
      deleteTierAt(pos);
    }
  }

  void deleteTierAt(int position) {
    tiers.removeAt(position);
  }

  @override
  bool operator ==(Object other) {
    if (other is! TextGrid) {
      return false;
    }
    return start == other.start &&
        end == other.end &&
        const ListEquality().equals(tiers, other.tiers);
  }

  @override
  int get hashCode => Object.hash(start, end, tiers);

  @override
  String toString() {
    return JsonMapper.serialize(this);
  }
}
