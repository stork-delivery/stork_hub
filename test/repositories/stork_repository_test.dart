import 'package:dart_stork_admin_client/dart_stork_admin_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockDartStorkAdminClient extends Mock implements DartStorkAdminClient {}

void main() {
  group('StorkRepository', () {
    late DartStorkAdminClient client;
    late StorkRepository repository;

    setUp(() {
      client = MockDartStorkAdminClient();
      repository = StorkRepository(client: client);
    });

    group('listApps', () {
      test('returns list of apps', () async {
        const storkApps = [
          StorkApp(id: 1, name: 'App 1'),
          StorkApp(id: 2, name: 'App 2'),
        ];

        when(() => client.listApps()).thenAnswer((_) async => storkApps);

        final apps = await repository.listApps();

        expect(
          apps,
          equals([
            const App(id: 1, name: 'App 1'),
            const App(id: 2, name: 'App 2'),
          ]),
        );

        verify(() => client.listApps()).called(1);
      });

      test('returns empty list when no apps', () async {
        when(() => client.listApps()).thenAnswer((_) async => []);

        final apps = await repository.listApps();

        expect(apps, isEmpty);
        verify(() => client.listApps()).called(1);
      });

      test('throws when client throws', () async {
        final exception = Exception('Failed to list apps');
        when(() => client.listApps()).thenThrow(exception);

        expect(
          () => repository.listApps(),
          throwsA(equals(exception)),
        );

        verify(() => client.listApps()).called(1);
      });
    });
  });
}
