import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/artifacts/artifacts.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockStorkRepository extends Mock implements StorkRepository {}

void main() {
  group('ArtifactsCubit', () {
    late StorkRepository storkRepository;
    late ArtifactsCubit cubit;

    const appId = 1;
    const versionId = 1;

    final artifacts = [
      const Artifact(
        id: 1,
        versionId: 1,
        name: 'app-release.apk',
        platform: 'android',
      ),
      const Artifact(
        id: 2,
        versionId: 1,
        name: 'app.ipa',
        platform: 'ios',
      ),
    ];

    setUp(() {
      storkRepository = MockStorkRepository();
      cubit = ArtifactsCubit(
        storkRepository: storkRepository,
        appId: appId,
        versionId: versionId,
      );
    });

    test('initial state is correct', () {
      expect(cubit.state, equals(const ArtifactsState()));
    });

    group('loadArtifacts', () {
      blocTest<ArtifactsCubit, ArtifactsState>(
        'emits loaded state when artifacts are loaded',
        setUp: () {
          when(
            () => storkRepository.listAppVersionArtifacts(appId, versionId),
          ).thenAnswer((_) async => artifacts);
        },
        build: () => cubit,
        act: (cubit) => cubit.loadArtifacts(),
        expect: () => [
          const ArtifactsState(status: ArtifactsStatus.loading),
          ArtifactsState(
            status: ArtifactsStatus.loaded,
            artifacts: artifacts,
          ),
        ],
        verify: (_) {
          verify(
            () => storkRepository.listAppVersionArtifacts(appId, versionId),
          ).called(1);
        },
      );

      blocTest<ArtifactsCubit, ArtifactsState>(
        'emits error state when loading fails',
        setUp: () {
          when(
            () => storkRepository.listAppVersionArtifacts(appId, versionId),
          ).thenThrow(Exception('Failed to load artifacts'));
        },
        build: () => cubit,
        act: (cubit) => cubit.loadArtifacts(),
        expect: () => [
          const ArtifactsState(status: ArtifactsStatus.loading),
          const ArtifactsState(
            status: ArtifactsStatus.error,
            error: 'Exception: Failed to load artifacts',
          ),
        ],
      );
    });
  });
}
