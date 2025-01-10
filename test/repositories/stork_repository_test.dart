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
          StorkApp(id: 1, name: 'App 1', publicMetadata: true),
          StorkApp(id: 2, name: 'App 2', publicMetadata: false),
        ];

        when(() => client.listApps()).thenAnswer((_) async => storkApps);

        final apps = await repository.listApps();

        expect(
          apps,
          equals([
            const App(id: 1, name: 'App 1', publicMetadata: true),
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

    group('createApp', () {
      test('creates a new app', () async {
        const storkApp = StorkApp(
          id: 1,
          name: 'Test App',
          publicMetadata: true,
        );

        when(
          () => client.createApp(
            name: 'Test App',
            publicMetadata: true,
          ),
        ).thenAnswer((_) async => storkApp);

        final app = await repository.createApp(
          name: 'Test App',
          publicMetadata: true,
        );

        expect(
          app,
          equals(
            const App(
              id: 1,
              name: 'Test App',
              publicMetadata: true,
            ),
          ),
        );

        verify(
          () => client.createApp(
            name: 'Test App',
            publicMetadata: true,
          ),
        ).called(1);
      });

      test('throws when client throws', () async {
        final exception = Exception('Failed to create app');
        when(
          () => client.createApp(
            name: any(named: 'name'),
            publicMetadata: any(named: 'publicMetadata'),
          ),
        ).thenThrow(exception);

        expect(
          () => repository.createApp(name: 'Test App'),
          throwsA(exception),
        );
      });
    });

    group('removeApp', () {
      test('removes an app', () async {
        when(() => client.removeApp(1)).thenAnswer((_) async {});

        await repository.removeApp(1);

        verify(() => client.removeApp(1)).called(1);
      });

      test('throws when client throws', () async {
        final exception = Exception('Failed to remove app');
        when(() => client.removeApp(any())).thenThrow(exception);

        expect(
          () => repository.removeApp(1),
          throwsA(exception),
        );
      });
    });

    group('updateApp', () {
      test('updates an app', () async {
        const storkApp = StorkApp(
          id: 1,
          name: 'Updated App',
          publicMetadata: true,
        );

        when(
          () => client.updateApp(
            id: 1,
            name: 'Updated App',
            publicMetadata: true,
          ),
        ).thenAnswer((_) async => storkApp);

        final app = await repository.updateApp(
          id: 1,
          name: 'Updated App',
          publicMetadata: true,
        );

        expect(
          app,
          equals(
            const App(
              id: 1,
              name: 'Updated App',
              publicMetadata: true,
            ),
          ),
        );

        verify(
          () => client.updateApp(
            id: 1,
            name: 'Updated App',
            publicMetadata: true,
          ),
        ).called(1);
      });

      test('throws when client throws', () async {
        final exception = Exception('Failed to update app');
        when(
          () => client.updateApp(
            id: any(named: 'id'),
            name: any(named: 'name'),
            publicMetadata: any(named: 'publicMetadata'),
          ),
        ).thenThrow(exception);

        expect(
          () => repository.updateApp(id: 1),
          throwsA(exception),
        );
      });
    });
  });
}
