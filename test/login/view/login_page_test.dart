// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/login/login.dart';
import 'package:stork_hub/repositories/api_key_repository.dart';

import '../../helpers/helpers.dart';

class MockApiKeyRepository extends Mock implements ApiKeyRepository {}

void main() {
  group('LoginPage', () {
    late ApiKeyRepository apiKeyRepository;

    setUp(() {
      apiKeyRepository = MockApiKeyRepository();

      when(() => apiKeyRepository.hasApiKey()).thenAnswer((_) async => false);
    });

    testWidgets('renders LoginForm', (tester) async {
      await tester.pumpApp(
        RepositoryProvider.value(
          value: apiKeyRepository,
          child: const LoginPage(),
        ),
      );

      expect(find.byType(LoginForm), findsOneWidget);
    });

    testWidgets('loads login state on initialization', (tester) async {
      await tester.pumpApp(
        RepositoryProvider.value(
          value: apiKeyRepository,
          child: const LoginPage(),
        ),
      );

      await tester.pump();

      verify(() => apiKeyRepository.hasApiKey()).called(1);
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      await tester.pumpApp(
        RepositoryProvider.value(
          value: apiKeyRepository,
          child: const LoginPage(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows login form after loading', (tester) async {
      await tester.pumpApp(
        RepositoryProvider.value(
          value: apiKeyRepository,
          child: const LoginPage(),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(TextField), findsWidgets);
    });
  });
}
