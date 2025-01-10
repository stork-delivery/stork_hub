// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:stork_hub/login/login.dart';

void main() {
  group('LoginState', () {
    test('supports value equality', () {
      expect(
        const LoginState(),
        equals(const LoginState()),
      );
    });

    test('default values are correct', () {
      expect(
        const LoginState(),
        equals(
          const LoginState(
            hasSavedKey: false,
            loading: false,
          ),
        ),
      );
    });

    group('copyWith', () {
      test('returns same object when no parameters are provided', () {
        expect(
          const LoginState().copyWith(),
          equals(const LoginState()),
        );
      });

      test('updates hasSavedKey when provided', () {
        expect(
          const LoginState().copyWith(hasSavedKey: true),
          equals(const LoginState(hasSavedKey: true)),
        );
      });

      test('updates loading when provided', () {
        expect(
          const LoginState().copyWith(loading: true),
          equals(const LoginState(loading: true)),
        );
      });

      test('can update multiple fields at once', () {
        expect(
          const LoginState().copyWith(
            hasSavedKey: true,
            loading: true,
          ),
          equals(
            const LoginState(
              hasSavedKey: true,
              loading: true,
            ),
          ),
        );
      });
    });

    test('props contains all fields', () {
      expect(
        const LoginState(
          hasSavedKey: true,
          loading: true,
        ).props,
        equals([true, true]),
      );
    });
  });
}
