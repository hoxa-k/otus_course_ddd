import 'package:ddd/models/points.dart';
import 'package:test/test.dart';

void main() {
  group('Points VO tests', () {
    test('Points creation test', () {
      expect(Points(24).count, 24);
    });

    test('Points creation fail test', () {
      expect(() => Points(-24), throwsA(isA<AssertionError>()));
    });

    test('Points equality test', () {
      expect(Points(24) == Points(24), true);
    });

    test('Points equality fail test', () {
      expect(Points(24) == Points(32), false);
    });
  });
}
