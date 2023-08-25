import 'package:collection/collection.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart'
    show JsonMapper, jsonSerializable, JsonProperty;
import 'package:flutter_textgrid/src/cloneable_interface.dart';
import 'package:flutter_textgrid/src/text_grid_type.dart';

import 'tier/tier.dart';

@jsonSerializable
class TextGrid implements ICloneable<TextGrid> {
  @JsonProperty()
  double start;

  @JsonProperty()
  double end;

  @JsonProperty()
  late List<Tier> tiers;

  @JsonProperty(ignore: true)
  TextGridType type;

  TextGrid({
    this.start = -1,
    this.end = -1,
    List<Tier>? tiers,
    this.type = TextGridType.long,
  }) : assert(
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

  @override
  TextGrid clone() {
    return TextGrid(
      start: start,
      end: end,
      type: type,
      tiers: tiers.deepClone(),
    );
  }
}
