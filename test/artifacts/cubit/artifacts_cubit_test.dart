// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/artifacts/artifacts.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockStorkRepository extends Mock implements StorkRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ArtifactsCubit', () {
    late StorkRepository repository;
    late ArtifactsCubit cubit;
    late GetSaveLocation getSaveLocation;

    const appId = 1;
    const versionName = '1.0.0';
    const savePath = '/path/to/artifact.zip';

    setUpAll(() {
      registerFallbackValue(File(''));
    });

    setUp(() {
      repository = MockStorkRepository();
      getSaveLocation = ({String? suggestedName}) async {
        return FileSaveLocation(savePath);
      };

      cubit = ArtifactsCubit(
        storkRepository: repository,
        appId: appId,
        versionName: versionName,
        getSaveLocation: getSaveLocation,
      );
    });

    test('initial state is correct', () {
      expect(cubit.state, equals(const ArtifactsState()));
    });

    group('loadArtifacts', () {
      const artifacts = [
        Artifact(
          id: 1,
          name: 'artifact.zip',
          versionId: 1,
          platform: 'linux',
        ),
      ];

      blocTest<ArtifactsCubit, ArtifactsState>(
        'emits loaded state when artifacts are loaded successfully',
        setUp: () {
          when(
            () => repository.listAppVersionArtifacts(appId, versionName),
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
            () => repository.listAppVersionArtifacts(appId, versionName),
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

    group('downloadArtifact', () {
      const platform = 'linux';
      const fileName = 'artifact.zip';

      blocTest<ArtifactsCubit, ArtifactsState>(
        'emits downloading and loaded states when download succeeds',
        setUp: () {
          when(
            () => repository.downloadArtifact(
              appId,
              versionName,
              platform,
              any(),
            ),
          ).thenAnswer((_) async {});
        },
        build: () => cubit,
        act: (cubit) => cubit.downloadArtifact(platform, fileName),
        expect: () => [
          const ArtifactsState(status: ArtifactsStatus.downloading),
          const ArtifactsState(
            status: ArtifactsStatus.loaded,
            downloadedFile: savePath,
          ),
        ],
      );

      blocTest<ArtifactsCubit, ArtifactsState>(
        'emits error state when download fails',
        setUp: () {
          when(
            () => repository.downloadArtifact(
              appId,
              versionName,
              platform,
              any(),
            ),
          ).thenThrow(Exception('Failed to download artifact'));
        },
        build: () => cubit,
        act: (cubit) => cubit.downloadArtifact(platform, fileName),
        expect: () => [
          const ArtifactsState(status: ArtifactsStatus.downloading),
          const ArtifactsState(
            status: ArtifactsStatus.error,
            error: 'Exception: Failed to download artifact',
          ),
        ],
      );

      blocTest<ArtifactsCubit, ArtifactsState>(
        'does not emit any state when user cancels file selection',
        build: () => ArtifactsCubit(
          storkRepository: repository,
          appId: appId,
          versionName: versionName,
          getSaveLocation: ({String? suggestedName}) async => null,
        ),
        act: (cubit) => cubit.downloadArtifact(platform, fileName),
        expect: () => <ArtifactsState>[],
      );
    });
  });
}
