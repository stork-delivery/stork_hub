// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/login/login.dart';
import 'package:stork_hub/repositories/api_key_repository.dart';

class MockApiKeyRepository extends Mock implements ApiKeyRepository {}

void main() {
  group('LoginCubit', () {
    late ApiKeyRepository apiKeyRepository;
    late LoginCubit cubit;

    setUp(() {
      apiKeyRepository = MockApiKeyRepository();
      cubit = LoginCubit(apiKeyRepository: apiKeyRepository);
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        equals(const LoginState()),
      );
    });

    group('load', () {
      blocTest<LoginCubit, LoginState>(
        'emits loading state and then result when key exists',
        build: () {
          when(() => apiKeyRepository.hasApiKey())
              .thenAnswer((_) async => true);
          return cubit;
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const LoginState(loading: true),
          const LoginState(hasSavedKey: true, loading: false),
        ],
        verify: (_) {
          verify(() => apiKeyRepository.hasApiKey()).called(1);
        },
      );

      blocTest<LoginCubit, LoginState>(
        'emits loading state and then result when key does not exist',
        build: () {
          when(() => apiKeyRepository.hasApiKey())
              .thenAnswer((_) async => false);
          return cubit;
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const LoginState(loading: true),
          const LoginState(hasSavedKey: false, loading: false),
        ],
        verify: (_) {
          verify(() => apiKeyRepository.hasApiKey()).called(1);
        },
      );

      blocTest<LoginCubit, LoginState>(
        'propagates repository errors',
        build: () {
          when(() => apiKeyRepository.hasApiKey())
              .thenThrow(Exception('Failed to check key'));
          return cubit;
        },
        act: (cubit) => cubit.load(),
        expect: () => [const LoginState(loading: true)],
        errors: () => [isA<Exception>()],
        verify: (_) {
          verify(() => apiKeyRepository.hasApiKey()).called(1);
        },
      );
    });

    group('resetKey', () {
      blocTest<LoginCubit, LoginState>(
        'emits loading state and then updates hasSavedKey to false',
        build: () {
          when(() => apiKeyRepository.deleteApiKey()).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.resetKey(),
        expect: () => [
          const LoginState(loading: true),
          const LoginState(hasSavedKey: false, loading: false),
        ],
        verify: (_) {
          verify(() => apiKeyRepository.deleteApiKey()).called(1);
        },
      );

      blocTest<LoginCubit, LoginState>(
        'propagates repository errors',
        build: () {
          when(() => apiKeyRepository.deleteApiKey())
              .thenThrow(Exception('Failed to delete key'));
          return cubit;
        },
        act: (cubit) => cubit.resetKey(),
        expect: () => [const LoginState(loading: true)],
        errors: () => [isA<Exception>()],
        verify: (_) {
          verify(() => apiKeyRepository.deleteApiKey()).called(1);
        },
      );
    });
  });
}
