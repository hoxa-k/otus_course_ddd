class Points {
  final int count;

  const Points._(this.count);

  const Points.zero(): count = 0;

  factory Points(int count) {
    if (count < 0) throw FormatException('Количество баллов не может быть отрицательным');
    return Points._(count);
  }

  Points add(int count) {
    return Points(this.count + count);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Points && count == other.count;
  }

  @override
  int get hashCode => count.hashCode;

  @override
  String toString() {
    return '$runtimeType ($count)';
  }
}
