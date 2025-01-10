import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/app_details/app_details.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockStorkRepository extends Mock implements StorkRepository {}

void main() {
  group('AppDetailsCubit', () {
    late StorkRepository storkRepository;
    late AppDetailsCubit cubit;

    const app = App(
      id: 1,
      name: 'Test App',
      publicMetadata: true,
    );

    final version = Version(
      id: 1,
      appId: app.id,
      version: '1.0.0',
      changelog: 'Changelog',
    );

    final versions = [version];

    setUp(() {
      storkRepository = MockStorkRepository();
      cubit = AppDetailsCubit(
        storkRepository: storkRepository,
        appId: app.id,
      );
    });

    test('initial state is correct', () {
      expect(cubit.state, equals(const AppDetailsState()));
    });

    group('loadApp', () {
      blocTest<AppDetailsCubit, AppDetailsState>(
        'emits loaded state when app is loaded',
        setUp: () {
          when(() => storkRepository.getApp(app.id))
              .thenAnswer((_) async => app);
          when(() => storkRepository.listAppVersions(app.id))
              .thenAnswer((_) async => versions);
        },
        build: () => cubit,
        act: (cubit) => cubit.loadApp(),
        expect: () => [
          const AppDetailsState(status: AppDetailsStatus.loading),
          AppDetailsState(
            status: AppDetailsStatus.loaded,
            app: app,
            versions: versions,
          ),
        ],
        verify: (_) {
          verify(() => storkRepository.getApp(app.id)).called(1);
          verify(() => storkRepository.listAppVersions(app.id)).called(1);
        },
      );

      blocTest<AppDetailsCubit, AppDetailsState>(
        'emits error state when loading app fails',
        setUp: () {
          when(() => storkRepository.getApp(app.id))
              .thenThrow(Exception('Failed to load app'));
        },
        build: () => cubit,
        act: (cubit) => cubit.loadApp(),
        expect: () => [
          const AppDetailsState(status: AppDetailsStatus.loading),
          const AppDetailsState(
            status: AppDetailsStatus.error,
            error: 'Exception: Failed to load app',
          ),
        ],
      );

      blocTest<AppDetailsCubit, AppDetailsState>(
        'emits error state when loading versions fails',
        setUp: () {
          when(() => storkRepository.getApp(app.id))
              .thenAnswer((_) async => app);
          when(() => storkRepository.listAppVersions(app.id))
              .thenThrow(Exception('Failed to load versions'));
        },
        build: () => cubit,
        act: (cubit) => cubit.loadApp(),
        expect: () => [
          const AppDetailsState(status: AppDetailsStatus.loading),
          const AppDetailsState(
            status: AppDetailsStatus.error,
            error: 'Exception: Failed to load versions',
          ),
        ],
        verify: (_) {
          verify(() => storkRepository.getApp(app.id)).called(1);
          verify(() => storkRepository.listAppVersions(app.id)).called(1);
        },
      );
    });

    group('updateApp', () {
      blocTest<AppDetailsCubit, AppDetailsState>(
        'emits loaded state when app is updated',
        setUp: () {
          when(() => storkRepository.updateApp(id: app.id, name: 'Updated'))
              .thenAnswer((_) async => app);
        },
        build: () => cubit,
        seed: () => const AppDetailsState(
          status: AppDetailsStatus.loaded,
          app: app,
        ),
        act: (cubit) => cubit.updateApp(name: 'Updated'),
        expect: () => [
          const AppDetailsState(
            status: AppDetailsStatus.loading,
            app: app,
          ),
          const AppDetailsState(
            status: AppDetailsStatus.loaded,
            app: app,
          ),
        ],
        verify: (_) {
          verify(() => storkRepository.updateApp(id: app.id, name: 'Updated'))
              .called(1);
        },
      );

      blocTest<AppDetailsCubit, AppDetailsState>(
        'emits error state when updating app fails',
        setUp: () {
          when(() => storkRepository.updateApp(id: app.id, name: 'Updated'))
              .thenThrow(Exception('Failed to update app'));
        },
        build: () => cubit,
        seed: () => const AppDetailsState(
          status: AppDetailsStatus.loaded,
          app: app,
        ),
        act: (cubit) => cubit.updateApp(name: 'Updated'),
        expect: () => [
          const AppDetailsState(
            status: AppDetailsStatus.loading,
            app: app,
          ),
          const AppDetailsState(
            status: AppDetailsStatus.error,
            app: app,
            error: 'Exception: Failed to update app',
          ),
        ],
      );
    });
  });
}
