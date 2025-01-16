import 'package:flutter_test/flutter_test.dart';
import 'package:stork_hub/models/models.dart';

void main() {
  group('ItchIOData', () {
    test('can be instantiated', () {
      expect(
        () => const ItchIOData(
          id: 1,
          appId: 2,
          buttlerKey: 'buttlerKey',
          itchIOUsername: 'username',
          itchIOGameName: 'gameName',
        ),
        returnsNormally,
      );
    });

    test('fromJson creates correct instance', () {
      final json = {
        'id': 1,
        'appId': 2,
        'buttlerKey': 'buttlerKey',
        'itchIOUsername': 'username',
        'itchIOGameName': 'gameName',
      };

      final data = ItchIOData.fromJson(json);

      expect(data.id, equals(1));
      expect(data.appId, equals(2));
      expect(data.buttlerKey, equals('buttlerKey'));
      expect(data.itchIOUsername, equals('username'));
      expect(data.itchIOGameName, equals('gameName'));
    });

    test('toJson creates correct map', () {
      const data = ItchIOData(
        id: 1,
        appId: 2,
        buttlerKey: 'buttlerKey',
        itchIOUsername: 'username',
        itchIOGameName: 'gameName',
      );

      final json = data.toJson();

      expect(
        json,
        equals({
          'id': 1,
          'appId': 2,
          'buttlerKey': 'buttlerKey',
          'itchIOUsername': 'username',
          'itchIOGameName': 'gameName',
        }),
      );
    });

    test('throws when required field is missing in json', () {
      final json = {
        'id': 1,
        'appId': 2,
        // buttlerKey is missing
        'itchIOUsername': 'username',
        'itchIOGameName': 'gameName',
      };

      expect(
        () => ItchIOData.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws when field has wrong type in json', () {
      final json = {
        'id': '1', // Should be int
        'appId': 2,
        'buttlerKey': 'buttlerKey',
        'itchIOUsername': 'username',
        'itchIOGameName': 'gameName',
      };

      expect(
        () => ItchIOData.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
