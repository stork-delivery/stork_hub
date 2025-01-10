import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/repositories/api_key_repository.dart';

class MockApiKeyRepository extends Mock implements ApiKeyRepository {}

void main() {
  group('AppCubit', () {
    late ApiKeyRepository apiKeyRepository;
    late AppCubit cubit;

    setUp(() {
      apiKeyRepository = MockApiKeyRepository();
      cubit = AppCubit(apiKeyRepository: apiKeyRepository);
    });

    test('initial state is correct', () {
      expect(cubit.state, equals(const AppState()));
    });

    group('setApiKey', () {
      test('updates state with new API key', () {
        const apiKey = 'test-api-key';
        cubit.setApiKey(apiKey);
        expect(cubit.state, equals(const AppState(apiKey: apiKey)));
      });

      test('can set API key to null', () {
        cubit.setApiKey(null);
        expect(cubit.state, equals(const AppState(apiKey: null)));
      });
    });

    group('saveAndSetApiKey', () {
      const apiKey = 'test-api-key';
      const password = 'test-password';

      blocTest<AppCubit, AppState>(
        'saves API key and updates state',
        build: () {
          when(
            () => apiKeyRepository.saveApiKey(
              apiKey: apiKey,
              password: password,
            ),
          ).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.saveAndSetApiKey(
          apiKey: apiKey,
          password: password,
        ),
        expect: () => [const AppState(apiKey: apiKey)],
        verify: (cubit) {
          verify(
            () => apiKeyRepository.saveApiKey(
              apiKey: apiKey,
              password: password,
            ),
          ).called(1);
        },
      );

      blocTest<AppCubit, AppState>(
        'propagates repository errors',
        build: () {
          when(
            () => apiKeyRepository.saveApiKey(
              apiKey: apiKey,
              password: password,
            ),
          ).thenThrow(Exception('Failed to save'));
          return cubit;
        },
        act: (cubit) => cubit.saveAndSetApiKey(
          apiKey: apiKey,
          password: password,
        ),
        errors: () => [isA<Exception>()],
        verify: (cubit) {
          verify(
            () => apiKeyRepository.saveApiKey(
              apiKey: apiKey,
              password: password,
            ),
          ).called(1);
        },
      );
    });

    group('unlockWithPassword', () {
      const apiKey = 'test-api-key';
      const password = 'test-password';

      blocTest<AppCubit, AppState>(
        'returns true and updates state when API key is found',
        build: () {
          when(
            () => apiKeyRepository.getApiKey(password: password),
          ).thenAnswer((_) async => apiKey);
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.unlockWithPassword(password);
          expect(result, isTrue);
        },
        expect: () => [const AppState(apiKey: apiKey)],
        verify: (cubit) {
          verify(
            () => apiKeyRepository.getApiKey(password: password),
          ).called(1);
        },
      );

      blocTest<AppCubit, AppState>(
        'returns false and keeps state when API key is not found',
        build: () {
          when(
            () => apiKeyRepository.getApiKey(password: password),
          ).thenAnswer((_) async => null);
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.unlockWithPassword(password);
          expect(result, isFalse);
        },
        expect: () => [], // No state changes
        verify: (cubit) {
          verify(
            () => apiKeyRepository.getApiKey(password: password),
          ).called(1);
        },
      );

      blocTest<AppCubit, AppState>(
        'propagates repository errors',
        build: () {
          when(
            () => apiKeyRepository.getApiKey(password: password),
          ).thenThrow(Exception('Failed to get key'));
          return cubit;
        },
        act: (cubit) => cubit.unlockWithPassword(password),
        errors: () => [isA<Exception>()],
        verify: (cubit) {
          verify(
            () => apiKeyRepository.getApiKey(password: password),
          ).called(1);
        },
      );
    });
  });
}
