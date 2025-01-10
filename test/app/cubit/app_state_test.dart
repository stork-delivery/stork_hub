import 'package:flutter_test/flutter_test.dart';
import 'package:stork_hub/app/app.dart';

void main() {
  group('AppState', () {
    test('can be instantiated', () {
      expect(
        const AppState(),
        isNotNull,
      );
    });

    test('supports value equality', () {
      expect(
        const AppState(),
        equals(const AppState()),
      );

      expect(
        const AppState(apiKey: 'test'),
        equals(const AppState(apiKey: 'test')),
      );
    });

    test('props contains apiKey', () {
      const apiKey = 'test-api-key';
      expect(
        const AppState(apiKey: apiKey).props,
        equals([apiKey]),
      );
    });

    test('different apiKey values are not equal', () {
      expect(
        const AppState(apiKey: 'test1'),
        isNot(equals(const AppState(apiKey: 'test2'))),
      );
    });

    test('null apiKey is not equal to non-null apiKey', () {
      expect(
        const AppState(),
        isNot(equals(const AppState(apiKey: 'test'))),
      );
    });

    test('toString returns meaningful description', () {
      expect(
        const AppState().toString(),
        'AppState(null)',
      );

      expect(
        const AppState(apiKey: 'test').toString(),
        'AppState(test)',
      );
    });
  });
}
