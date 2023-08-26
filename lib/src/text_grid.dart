import 'package:collection/collection.dart';
import 'package:flutter_textgrid/src/cloneable_interface.dart';

import 'tier/tier.dart';
import 'utils/utils.dart';

class TextGrid implements ICloneable<TextGrid> {
  Time startTime;
  Time endTime;

  late List<Tier> tiers;

  TextGrid({
    this.startTime = Time.zero,
    this.endTime = Time.zero,
    List<Tier>? tiers,
  }) {
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
    return startTime == other.startTime &&
        endTime == other.endTime &&
        const ListEquality().equals(tiers, other.tiers);
  }

  @override
  int get hashCode => Object.hash(startTime, endTime, tiers);

  @override
  TextGrid clone() {
    return TextGrid(
      startTime: startTime,
      endTime: endTime,
      tiers: tiers.deepClone(),
    );
  }
}
