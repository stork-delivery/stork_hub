import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/environment/app_environment.dart';
import 'package:stork_hub/home/home.dart';
import 'package:stork_hub/login/login.dart';
import 'package:stork_hub/repositories/api_key_repository.dart';

import '../../helpers/helpers.dart';

class MockApiKeyRepository extends Mock implements ApiKeyRepository {}

void main() {
  group('App', () {
    late ApiKeyRepository apiKeyRepository;

    setUp(() {
      apiKeyRepository = MockApiKeyRepository();
    });

    testWidgets('renders LoginPage when no key exists', (tester) async {
      when(() => apiKeyRepository.hasApiKey())
          .thenAnswer((_) => Future.value(false));

      await tester.pumpApp(
        App(
          environment: const AppEnvironment(),
          apiKeyRepository: apiKeyRepository,
        ),
      );

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('renders LoginPage when key exists but not unlocked',
        (tester) async {
      when(() => apiKeyRepository.hasApiKey())
          .thenAnswer((_) => Future.value(true));

      await tester.pumpApp(
        App(
          environment: const AppEnvironment(),
          apiKeyRepository: apiKeyRepository,
        ),
      );

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });
  });
}
