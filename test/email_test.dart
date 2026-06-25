import 'package:ddd/domain/models/email.dart';
import 'package:test/test.dart';

void main() {
  group('Email VO tests', () {
    test('Email creation test', () {
      expect(Email('info@otus.ru').name, 'info@otus.ru');
    });

    test('Email creation fail test', () {
      expect(() => Email('info_otus.ru'), throwsA(isA<FormatException>()));
    });

    test('Email equality test', () {
      expect(Email('info@otus.ru') == Email('info@otus.ru'), true);
    });

    test('Email equality fail test', () {
      expect(Email('info@otus.ru') == Email('admin@otus.ru'), false);
    });
  });
}
