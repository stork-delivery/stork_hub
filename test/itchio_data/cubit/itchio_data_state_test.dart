// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:stork_hub/itchio_data/itchio_data.dart';
import 'package:stork_hub/models/models.dart';

void main() {
  group('ItchIODataState', () {
    const itchIOData = ItchIOData(
      id: 1,
      appId: 1,
      buttlerKey: 'test-key',
      itchIOUsername: 'test-user',
      itchIOGameName: 'test-game',
    );

    test('supports value equality', () {
      expect(
        const ItchIODataState(),
        equals(const ItchIODataState()),
      );
    });

    test('props are correct', () {
      expect(
        const ItchIODataState(
          status: ItchIODataStatus.initial,
          data: itchIOData,
          error: 'error',
        ).props,
        equals([ItchIODataStatus.initial, itchIOData, 'error']),
      );
    });

    group('copyWith', () {
      test('returns same object when no parameters are provided', () {
        expect(
          const ItchIODataState().copyWith(),
          equals(const ItchIODataState()),
        );
      });

      test('returns object with updated status when status is provided', () {
        expect(
          const ItchIODataState().copyWith(
            status: ItchIODataStatus.loading,
          ),
          equals(
            const ItchIODataState(status: ItchIODataStatus.loading),
          ),
        );
      });

      test('returns object with updated data when data is provided', () {
        expect(
          const ItchIODataState().copyWith(
            data: itchIOData,
          ),
          equals(
            const ItchIODataState(data: itchIOData),
          ),
        );
      });

      test('returns object with updated error when error is provided', () {
        expect(
          const ItchIODataState().copyWith(
            error: 'error',
          ),
          equals(
            const ItchIODataState(error: 'error'),
          ),
        );
      });

      test(
          'returns object with updated values when multiple parameters '
          'provided', () {
        expect(
          const ItchIODataState().copyWith(
            status: ItchIODataStatus.loaded,
            data: itchIOData,
            error: 'error',
          ),
          equals(
            const ItchIODataState(
              status: ItchIODataStatus.loaded,
              data: itchIOData,
              error: 'error',
            ),
          ),
        );
      });
    });
  });
}
