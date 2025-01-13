// ignore_for_file: avoid_redundant_argument_values, inference_failure_on_collection_literal

import 'package:flutter_test/flutter_test.dart';
import 'package:stork_hub/artifacts/artifacts.dart';
import 'package:stork_hub/models/models.dart';

void main() {
  group('ArtifactsState', () {
    test('supports value equality', () {
      expect(
        const ArtifactsState(),
        equals(const ArtifactsState()),
      );
    });

    test('props are correct', () {
      expect(
        const ArtifactsState(
          status: ArtifactsStatus.initial,
          artifacts: [],
          error: null,
        ).props,
        equals([ArtifactsStatus.initial, const [], null]),
      );
    });

    group('copyWith', () {
      test('returns same object when no parameters are provided', () {
        expect(
          const ArtifactsState().copyWith(),
          equals(const ArtifactsState()),
        );
      });

      test('returns object with updated status when status is provided', () {
        expect(
          const ArtifactsState().copyWith(
            status: ArtifactsStatus.loading,
          ),
          equals(
            const ArtifactsState(
              status: ArtifactsStatus.loading,
            ),
          ),
        );
      });

      test('returns object with updated artifacts when artifacts is provided',
          () {
        const artifacts = [
          Artifact(
            id: 1,
            name: 'artifact.zip',
            versionId: 1,
            platform: 'linux',
          ),
        ];

        expect(
          const ArtifactsState().copyWith(
            artifacts: artifacts,
          ),
          equals(
            const ArtifactsState(
              artifacts: artifacts,
            ),
          ),
        );
      });

      test('returns object with updated error when error is provided', () {
        expect(
          const ArtifactsState().copyWith(
            error: 'error',
          ),
          equals(
            const ArtifactsState(
              error: 'error',
            ),
          ),
        );
      });
    });

    group('constructor', () {
      test('works correctly', () {
        const artifacts = [
          Artifact(
            id: 1,
            name: 'artifact.zip',
            versionId: 1,
            platform: 'linux',
          ),
        ];

        const state = ArtifactsState(
          status: ArtifactsStatus.loaded,
          artifacts: artifacts,
          error: 'error',
        );

        expect(state.status, equals(ArtifactsStatus.loaded));
        expect(state.artifacts, equals(artifacts));
        expect(state.error, equals('error'));
      });

      test('default values are correct', () {
        const state = ArtifactsState();

        expect(state.status, equals(ArtifactsStatus.initial));
        expect(state.artifacts, equals(const []));
        expect(state.error, isNull);
      });
    });
  });
}
