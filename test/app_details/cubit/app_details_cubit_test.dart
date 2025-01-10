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

    setUp(() {
      storkRepository = MockStorkRepository();
      cubit = AppDetailsCubit(
        storkRepository: storkRepository,
        appId: 1,
      );
    });

    test('initial state is correct', () {
      expect(cubit.state, equals(const AppDetailsState()));
    });

    group('loadApp', () {
      final apps = [
        const App(id: 1, name: 'Test App 1', publicMetadata: true),
        const App(id: 2, name: 'Test App 2'),
      ];

      blocTest<AppDetailsCubit, AppDetailsState>(
        'emits loading and loaded states when successful',
        build: () {
          when(() => storkRepository.listApps()).thenAnswer((_) async => apps);
          return cubit;
        },
        act: (cubit) => cubit.loadApp(),
        expect: () => [
          const AppDetailsState(status: AppDetailsStatus.loading),
          AppDetailsState(
            status: AppDetailsStatus.loaded,
            app: apps[0],
          ),
        ],
        verify: (_) {
          verify(() => storkRepository.listApps()).called(1);
        },
      );

      blocTest<AppDetailsCubit, AppDetailsState>(
        'emits loading and error states when repository throws',
        build: () {
          when(() => storkRepository.listApps())
              .thenThrow(Exception('Failed to load apps'));
          return cubit;
        },
        act: (cubit) => cubit.loadApp(),
        expect: () => [
          const AppDetailsState(status: AppDetailsStatus.loading),
          const AppDetailsState(
            status: AppDetailsStatus.error,
            error: 'Exception: Failed to load apps',
          ),
        ],
      );
    });

    group('updateApp', () {
      const app = App(id: 1, name: 'Test App', publicMetadata: true);
      const updatedApp = App(
        id: 1,
        name: 'Updated App',
      );

      blocTest<AppDetailsCubit, AppDetailsState>(
        'emits loading and loaded states when successful',
        seed: () => const AppDetailsState(
          status: AppDetailsStatus.loaded,
          app: app,
        ),
        build: () {
          when(
            () => storkRepository.updateApp(
              id: 1,
              name: 'Updated App',
              publicMetadata: false,
            ),
          ).thenAnswer((_) async => updatedApp);
          return cubit;
        },
        act: (cubit) => cubit.updateApp(
          name: 'Updated App',
          publicMetadata: false,
        ),
        expect: () => [
          const AppDetailsState(
            status: AppDetailsStatus.loading,
            app: app,
          ),
          const AppDetailsState(
            status: AppDetailsStatus.loaded,
            app: updatedApp,
          ),
        ],
        verify: (_) {
          verify(
            () => storkRepository.updateApp(
              id: 1,
              name: 'Updated App',
              publicMetadata: false,
            ),
          ).called(1);
        },
      );

      blocTest<AppDetailsCubit, AppDetailsState>(
        'emits loading and error states when repository throws',
        seed: () => const AppDetailsState(
          status: AppDetailsStatus.loaded,
          app: app,
        ),
        build: () {
          when(
            () => storkRepository.updateApp(
              id: any(named: 'id'),
              name: any(named: 'name'),
              publicMetadata: any(named: 'publicMetadata'),
            ),
          ).thenThrow(Exception('Failed to update app'));
          return cubit;
        },
        act: (cubit) => cubit.updateApp(
          name: 'Updated App',
          publicMetadata: false,
        ),
        expect: () => [
          const AppDetailsState(
            status: AppDetailsStatus.loading,
            app: app,
          ),
          const AppDetailsState(
            status: AppDetailsStatus.error,
            error: 'Exception: Failed to update app',
            app: app,
          ),
        ],
      );

      blocTest<AppDetailsCubit, AppDetailsState>(
        'does nothing when app is null',
        build: () => cubit,
        act: (cubit) => cubit.updateApp(
          name: 'Updated App',
          publicMetadata: false,
        ),
        expect: () => const <AppDetailsState>[],
        verify: (_) {
          verifyNever(
            () => storkRepository.updateApp(
              id: any(named: 'id'),
              name: any(named: 'name'),
              publicMetadata: any(named: 'publicMetadata'),
            ),
          );
        },
      );
    });
  });
}
