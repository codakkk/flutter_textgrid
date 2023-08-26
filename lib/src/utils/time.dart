class Time implements Comparable<Time> {
  final double _value;

  double get value => _value;

  // A representation of point in time with a predefined precision.
  static const double _precision = 0.0001;

  static const Time zero = Time(0.0);

  const Time(double value) : _value = value;
  factory Time.int(int value) => value.toTime();

  @override
  bool operator ==(Object other) {
    if (other is Time) {
      return (_value - other._value).abs() < _precision;
    }
    if (other is num) {
      return (_value - other).abs() < _precision;
    }
    return false;
  }

  @override
  int get hashCode => _value.hashCode;

  bool operator >(Time other) => this != other && _value - other._value > 0;

  bool operator <(Time other) => this != other && _value - other._value < 0;

  bool operator >=(Time other) => this == other || this > other;

  bool operator <=(Time other) => this == other || this < other;

  Time operator -(Time other) => Time(_value - other.value);
  Time operator +(Time other) => Time(_value + other.value);

  static Time min(Time t1, Time t2) {
    return t1 >= t2 ? t2 : t1;
  }

  static Time max(Time t1, Time t2) {
    return t1 >= t2 ? t1 : t2;
  }

  @override
  int compareTo(Time other) {
    if (this < other) return -1;
    if (this > other) return 1;
    return 0;
  }
}

extension DoubleToTimeX on num {
  Time toTime() {
    final t = this;
    if (t is int) {
      return Time(t.toDouble());
    } else if (t is double) {
      return Time(t);
    }

    throw StateError("Unsupported num");
  }
}
