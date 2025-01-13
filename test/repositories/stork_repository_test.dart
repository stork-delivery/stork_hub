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

    group('getApp', () {
      test('returns app', () async {
        const storkApp = StorkApp(
          id: 1,
          name: 'Test App',
          publicMetadata: true,
        );

        when(() => client.getApp(1)).thenAnswer((_) async => storkApp);

        final app = await repository.getApp(1);

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

        verify(() => client.getApp(1)).called(1);
      });

      test('throws when client throws', () async {
        final exception = Exception('Failed to get app');
        when(() => client.getApp(any())).thenThrow(exception);

        expect(
          () => repository.getApp(1),
          throwsA(exception),
        );
      });
    });

    group('listAppVersions', () {
      test('returns list of versions', () async {
        const storkVersion = StorkAppVersion(
          id: 1,
          appId: 1,
          version: '1.0.0',
          changelog: 'Initial release',
        );

        when(() => client.listVersions(1))
            .thenAnswer((_) async => [storkVersion]);

        final versions = await repository.listAppVersions(1);

        expect(
          versions,
          equals([
            const Version(
              id: 1,
              appId: 1,
              version: '1.0.0',
              changelog: 'Initial release',
            ),
          ]),
        );

        verify(() => client.listVersions(1)).called(1);
      });

      test('throws when client throws', () async {
        final exception = Exception('Failed to list versions');
        when(() => client.listVersions(any())).thenThrow(exception);

        expect(
          () => repository.listAppVersions(1),
          throwsA(exception),
        );
      });
    });

    group('getAppVersion', () {
      test('returns version', () async {
        const storkVersion = StorkAppVersion(
          id: 1,
          appId: 1,
          version: '1.0.0',
          changelog: 'Initial release',
        );

        when(() => client.getVersion(1, 1))
            .thenAnswer((_) async => storkVersion);

        final version = await repository.getAppVersion(1, 1);

        expect(
          version,
          equals(
            const Version(
              id: 1,
              appId: 1,
              version: '1.0.0',
              changelog: 'Initial release',
            ),
          ),
        );

        verify(() => client.getVersion(1, 1)).called(1);
      });

      test('throws when client throws', () async {
        final exception = Exception('Failed to get version');
        when(() => client.getVersion(any(), any())).thenThrow(exception);

        expect(
          () => repository.getAppVersion(1, 1),
          throwsA(exception),
        );
      });
    });

    group('listAppVersionArtifacts', () {
      test('returns list of artifacts', () async {
        const storkArtifacts = [
          StorkAppVersionArtifact(
            id: 1,
            versionId: 1,
            name: 'app-release.apk',
            platform: 'android',
          ),
          StorkAppVersionArtifact(
            id: 2,
            versionId: 1,
            name: 'app.ipa',
            platform: 'ios',
          ),
        ];

        when(() => client.listArtifacts(1, 1))
            .thenAnswer((_) async => storkArtifacts);

        final result = await repository.listAppVersionArtifacts(1, 1);

        expect(
          result,
          equals([
            const Artifact(
              id: 1,
              versionId: 1,
              name: 'app-release.apk',
              platform: 'android',
            ),
            const Artifact(
              id: 2,
              versionId: 1,
              name: 'app.ipa',
              platform: 'ios',
            ),
          ]),
        );
        verify(() => client.listArtifacts(1, 1)).called(1);
      });

      test('throws when client throws', () async {
        final exception = Exception('Failed to list artifacts');
        when(() => client.listArtifacts(any(), any())).thenThrow(exception);

        expect(
          () => repository.listAppVersionArtifacts(1, 1),
          throwsA(exception),
        );
      });
    });
  });
}
