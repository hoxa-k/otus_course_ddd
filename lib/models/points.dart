class Points {
  final int count;

  Points(this.count) {
    assert(count >= 0, 'Количество баллов не может быть отрицательным');
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
