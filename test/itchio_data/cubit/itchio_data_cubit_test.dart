import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/itchio_data/itchio_data.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockStorkRepository extends Mock implements StorkRepository {}

void main() {
  group('ItchIODataCubit', () {
    late StorkRepository storkRepository;
    late ItchIODataCubit cubit;

    const appId = 1;
    const itchIOData = ItchIOData(
      id: 1,
      appId: appId,
      buttlerKey: 'test-key',
      itchIOUsername: 'test-user',
      itchIOGameName: 'test-game',
    );

    setUp(() {
      storkRepository = MockStorkRepository();
      cubit = ItchIODataCubit(
        storkRepository: storkRepository,
        appId: appId,
      );
    });

    test('initial state is correct', () {
      expect(cubit.state, const ItchIODataState());
    });

    group('loadItchIOData', () {
      blocTest<ItchIODataCubit, ItchIODataState>(
        'emits [loading, loaded] when successful',
        setUp: () {
          when(() => storkRepository.getAppItchIOData(appId))
              .thenAnswer((_) async => itchIOData);
        },
        build: () => cubit,
        act: (cubit) => cubit.loadItchIOData(),
        expect: () => [
          const ItchIODataState(status: ItchIODataStatus.loading),
          const ItchIODataState(
            status: ItchIODataStatus.loaded,
            data: itchIOData,
          ),
        ],
        verify: (_) {
          verify(() => storkRepository.getAppItchIOData(appId)).called(1);
        },
      );

      blocTest<ItchIODataCubit, ItchIODataState>(
        'emits [loading, error] when fails',
        setUp: () {
          when(() => storkRepository.getAppItchIOData(appId))
              .thenThrow(Exception('error'));
        },
        build: () => cubit,
        act: (cubit) => cubit.loadItchIOData(),
        expect: () => [
          const ItchIODataState(status: ItchIODataStatus.loading),
          const ItchIODataState(
            status: ItchIODataStatus.error,
            error: 'Failed to load ItchIO data',
          ),
        ],
      );
    });

    group('updateItchIOData', () {
      const newItchIOData = ItchIOData(
        id: 1,
        appId: appId,
        buttlerKey: 'new-key',
        itchIOUsername: 'new-user',
        itchIOGameName: 'new-game',
      );

      blocTest<ItchIODataCubit, ItchIODataState>(
        'emits [saving, loaded] when successful',
        setUp: () {
          when(
            () => storkRepository.updateAppItchIOData(
              appId: appId,
              buttlerKey: newItchIOData.buttlerKey,
              itchIOUsername: newItchIOData.itchIOUsername,
              itchIOGameName: newItchIOData.itchIOGameName,
            ),
          ).thenAnswer((_) async => newItchIOData);
        },
        build: () => cubit,
        act: (cubit) => cubit.updateItchIOData(
          buttlerKey: newItchIOData.buttlerKey,
          itchIOUsername: newItchIOData.itchIOUsername,
          itchIOGameName: newItchIOData.itchIOGameName,
        ),
        expect: () => [
          const ItchIODataState(status: ItchIODataStatus.saving),
          const ItchIODataState(
            status: ItchIODataStatus.loaded,
            data: newItchIOData,
          ),
        ],
        verify: (_) {
          verify(
            () => storkRepository.updateAppItchIOData(
              appId: appId,
              buttlerKey: newItchIOData.buttlerKey,
              itchIOUsername: newItchIOData.itchIOUsername,
              itchIOGameName: newItchIOData.itchIOGameName,
            ),
          ).called(1);
        },
      );

      blocTest<ItchIODataCubit, ItchIODataState>(
        'emits [saving, error] when fails',
        setUp: () {
          when(
            () => storkRepository.updateAppItchIOData(
              appId: appId,
              buttlerKey: newItchIOData.buttlerKey,
              itchIOUsername: newItchIOData.itchIOUsername,
              itchIOGameName: newItchIOData.itchIOGameName,
            ),
          ).thenThrow(Exception('error'));
        },
        build: () => cubit,
        act: (cubit) => cubit.updateItchIOData(
          buttlerKey: newItchIOData.buttlerKey,
          itchIOUsername: newItchIOData.itchIOUsername,
          itchIOGameName: newItchIOData.itchIOGameName,
        ),
        expect: () => [
          const ItchIODataState(status: ItchIODataStatus.saving),
          const ItchIODataState(
            status: ItchIODataStatus.error,
            error: 'Failed to save ItchIO data',
          ),
        ],
      );
    });
  });
}
