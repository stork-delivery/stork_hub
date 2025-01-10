// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:stork_hub/home/home.dart';
import 'package:stork_hub/models/models.dart';

void main() {
  group('HomeState', () {
    test('supports value equality', () {
      expect(
        const HomeState(),
        equals(const HomeState()),
      );
    });

    test('default values are correct', () {
      expect(
        const HomeState(),
        equals(
          const HomeState(
            status: HomeStatus.initial,
            apps: [],
            error: null,
          ),
        ),
      );
    });

    group('copyWith', () {
      test('returns same object when no parameters are provided', () {
        expect(
          const HomeState().copyWith(),
          equals(const HomeState()),
        );
      });

      test('updates status when provided', () {
        expect(
          const HomeState().copyWith(status: HomeStatus.loading),
          equals(const HomeState(status: HomeStatus.loading)),
        );
      });

      test('updates apps when provided', () {
        final apps = [
          const App(id: 1, name: 'Test App'),
        ];
        expect(
          const HomeState().copyWith(apps: apps),
          equals(HomeState(apps: apps)),
        );
      });

      test('updates error when provided', () {
        expect(
          const HomeState().copyWith(error: 'error'),
          equals(const HomeState(error: 'error')),
        );
      });

      test('can update multiple fields at once', () {
        final apps = [
          const App(id: 1, name: 'Test App'),
        ];
        expect(
          const HomeState().copyWith(
            status: HomeStatus.loaded,
            apps: apps,
            error: 'error',
          ),
          equals(
            HomeState(
              status: HomeStatus.loaded,
              apps: apps,
              error: 'error',
            ),
          ),
        );
      });
    });

    test('props contains all fields', () {
      final apps = [
        const App(id: 1, name: 'Test App'),
      ];
      expect(
        HomeState(
          status: HomeStatus.loaded,
          apps: apps,
          error: 'error',
        ).props,
        equals([HomeStatus.loaded, apps, 'error']),
      );
    });
  });
}
