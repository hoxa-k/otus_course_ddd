import 'package:ddd/models/points.dart';
import 'package:test/test.dart';

void main() {
  group('Money VO tests', () {
    test('Money creation test', () {
      expect(Points(24).count, 24);
    });

    test('Money creation fail test', () {
      expect(() => Points(-24), throwsA(isA<AssertionError>()));
    });

    test('Money equality test', () {
      expect(Points(24) == Points(24), true);
    });

    test('Money equality fail test', () {
      expect(Points(24) == Points(32), false);
    });
  });
}
