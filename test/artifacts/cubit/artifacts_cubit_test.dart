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
    const versionName = '1.0.0';
    const artifacts = [
      Artifact(
        id: 1,
        name: 'artifact.zip',
        versionId: 1,
        platform: 'linux',
      ),
    ];

    setUp(() {
      storkRepository = MockStorkRepository();
      cubit = ArtifactsCubit(
        storkRepository: storkRepository,
        appId: appId,
        versionName: versionName,
      );
    });

    test('initial state is correct', () {
      expect(cubit.state, equals(const ArtifactsState()));
    });

    group('loadArtifacts', () {
      blocTest<ArtifactsCubit, ArtifactsState>(
        'emits loaded state when artifacts are loaded successfully',
        setUp: () {
          when(
            () => storkRepository.listAppVersionArtifacts(appId, versionName),
          ).thenAnswer((_) async => artifacts);
        },
        build: () => cubit,
        act: (cubit) => cubit.loadArtifacts(),
        expect: () => [
          const ArtifactsState(status: ArtifactsStatus.loading),
          const ArtifactsState(
            status: ArtifactsStatus.loaded,
            artifacts: artifacts,
          ),
        ],
      );

      blocTest<ArtifactsCubit, ArtifactsState>(
        'emits error state when loading artifacts fails',
        setUp: () {
          when(
            () => storkRepository.listAppVersionArtifacts(appId, versionName),
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
