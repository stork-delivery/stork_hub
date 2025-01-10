// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/home/home.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockStorkRepository extends Mock implements StorkRepository {}

void main() {
  group('HomeCubit', () {
    late StorkRepository storkRepository;
    late HomeCubit cubit;

    setUp(() {
      storkRepository = MockStorkRepository();
      cubit = HomeCubit(storkRepository: storkRepository);
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        equals(const HomeState()),
      );
    });

    group('loadApps', () {
      final apps = [
        const App(id: 1, name: 'Test App 1'),
        const App(id: 2, name: 'Test App 2'),
      ];

      blocTest<HomeCubit, HomeState>(
        'emits loading and loaded states when successful',
        build: () {
          when(() => storkRepository.listApps()).thenAnswer((_) async => apps);
          return cubit;
        },
        act: (cubit) => cubit.loadApps(),
        expect: () => [
          const HomeState(status: HomeStatus.loading),
          HomeState(status: HomeStatus.loaded, apps: apps),
        ],
        verify: (_) {
          verify(() => storkRepository.listApps()).called(1);
        },
      );

      blocTest<HomeCubit, HomeState>(
        'emits loading and error states when repository throws',
        build: () {
          when(() => storkRepository.listApps())
              .thenThrow(Exception('Failed to load apps'));
          return cubit;
        },
        act: (cubit) => cubit.loadApps(),
        expect: () => [
          const HomeState(status: HomeStatus.loading),
          const HomeState(
            status: HomeStatus.error,
            error: 'Exception: Failed to load apps',
          ),
        ],
        verify: (_) {
          verify(() => storkRepository.listApps()).called(1);
        },
      );
    });

    group('addApp', () {
      const newApp = App(id: 1, name: 'New App');

      blocTest<HomeCubit, HomeState>(
        'emits loading and loaded states when successful',
        build: () {
          when(
            () => storkRepository.createApp(name: 'New App'),
          ).thenAnswer((_) async => newApp);
          return cubit;
        },
        act: (cubit) => cubit.addApp('New App'),
        expect: () => [
          const HomeState(status: HomeStatus.loading),
          const HomeState(
            status: HomeStatus.loaded,
            apps: [newApp],
          ),
        ],
        verify: (_) {
          verify(
            () => storkRepository.createApp(name: 'New App'),
          ).called(1);
        },
      );

      blocTest<HomeCubit, HomeState>(
        'emits loading and error states when repository throws',
        build: () {
          when(
            () => storkRepository.createApp(name: any(named: 'name')),
          ).thenThrow(Exception('Failed to create app'));
          return cubit;
        },
        act: (cubit) => cubit.addApp('New App'),
        expect: () => [
          const HomeState(status: HomeStatus.loading),
          const HomeState(
            status: HomeStatus.error,
            error: 'Exception: Failed to create app',
          ),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'adds app to existing list',
        seed: () => const HomeState(
          status: HomeStatus.loaded,
          apps: [App(id: 1, name: 'Existing App')],
        ),
        build: () {
          when(
            () => storkRepository.createApp(name: 'New App'),
          ).thenAnswer(
            (_) async => const App(id: 2, name: 'New App'),
          );
          return cubit;
        },
        act: (cubit) => cubit.addApp('New App'),
        expect: () => [
          const HomeState(
            status: HomeStatus.loading,
            apps: [App(id: 1, name: 'Existing App')],
          ),
          const HomeState(
            status: HomeStatus.loaded,
            apps: [
              App(id: 1, name: 'Existing App'),
              App(id: 2, name: 'New App'),
            ],
          ),
        ],
      );
    });

    group('removeApp', () {
      const app1 = App(id: 1, name: 'App 1');
      const app2 = App(id: 2, name: 'App 2');

      blocTest<HomeCubit, HomeState>(
        'emits loading and loaded states when successful',
        seed: () => const HomeState(
          status: HomeStatus.loaded,
          apps: [app1, app2],
        ),
        build: () {
          when(() => storkRepository.removeApp(1)).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.removeApp(app1),
        expect: () => [
          const HomeState(
            status: HomeStatus.loading,
            apps: [app1, app2],
          ),
          const HomeState(
            status: HomeStatus.loaded,
            apps: [app2],
          ),
        ],
        verify: (_) {
          verify(() => storkRepository.removeApp(1)).called(1);
        },
      );

      blocTest<HomeCubit, HomeState>(
        'emits loading and error states when repository throws',
        seed: () => const HomeState(
          status: HomeStatus.loaded,
          apps: [app1],
        ),
        build: () {
          when(
            () => storkRepository.removeApp(any()),
          ).thenThrow(Exception('Failed to remove app'));
          return cubit;
        },
        act: (cubit) => cubit.removeApp(app1),
        expect: () => [
          const HomeState(
            status: HomeStatus.loading,
            apps: [app1],
          ),
          const HomeState(
            status: HomeStatus.error,
            error: 'Exception: Failed to remove app',
            apps: [app1],
          ),
        ],
      );
    });
  });
}
