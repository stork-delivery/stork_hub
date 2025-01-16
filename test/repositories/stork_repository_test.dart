// ignore_for_file: prefer_const_constructors

import 'dart:io';

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
        final storkVersion = StorkAppVersion(
          id: 1,
          appId: 1,
          version: '1.0.0',
          changelog: 'Initial release',
          createdAt: DateTime.now(),
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
      test('returns a version', () async {
        final version = Version(
          id: 1,
          appId: 1,
          version: '1.0.0',
          changelog: 'Initial release',
        );

        when(
          () => client.getVersion(1, '1.0.0'),
        ).thenAnswer(
          (_) async => StorkAppVersion(
            id: version.id,
            appId: version.appId,
            version: version.version,
            changelog: version.changelog,
            createdAt: DateTime.now(),
          ),
        );

        final result = await repository.getAppVersion(1, '1.0.0');
        expect(result, version);
      });

      test('throws an exception when the request fails', () {
        when(
          () => client.getVersion(1, '1.0.0'),
        ).thenThrow(Exception('Failed to get version'));

        expect(
          () => repository.getAppVersion(1, '1.0.0'),
          throwsException,
        );
      });
    });

    group('listAppVersionArtifacts', () {
      test('returns a list of artifacts', () async {
        final artifacts = [
          Artifact(
            id: 1,
            name: 'artifact.zip',
            versionId: 1,
            platform: 'linux',
          ),
        ];

        when(
          () => client.listArtifacts(1, '1.0.0'),
        ).thenAnswer(
          (_) async => artifacts
              .map(
                (artifact) => StorkAppVersionArtifact(
                  id: artifact.id,
                  name: artifact.name,
                  versionId: artifact.versionId,
                  platform: artifact.platform,
                ),
              )
              .toList(),
        );

        final result = await repository.listAppVersionArtifacts(1, '1.0.0');
        expect(result, artifacts);
      });

      test('throws an exception when the request fails', () {
        when(
          () => client.listArtifacts(1, '1.0.0'),
        ).thenThrow(Exception('Failed to list artifacts'));

        expect(
          () => repository.listAppVersionArtifacts(1, '1.0.0'),
          throwsException,
        );
      });
    });

    group('downloadArtifact', () {
      setUp(() {
        Directory('test/tmp').createSync(recursive: true);
      });

      tearDown(() {
        if (Directory('test/tmp').existsSync()) {
          Directory('test/tmp').deleteSync(recursive: true);
        }
      });

      test('saves artifact to file', () async {
        final bytes = List.generate(10, (index) => index);
        final file = File('test/tmp/artifact.zip');

        when(
          () => client.downloadArtifact(1, '1.0.0', 'linux'),
        ).thenAnswer((_) async => bytes);

        await repository.downloadArtifact(1, '1.0.0', 'linux', file);

        expect(file.existsSync(), isTrue);
        expect(await file.readAsBytes(), bytes);

        // Cleanup
        await file.delete();
      });

      test('throws an exception when the request fails', () {
        final file = File('test/tmp/artifact.zip');

        when(
          () => client.downloadArtifact(1, '1.0.0', 'linux'),
        ).thenThrow(Exception('Failed to download artifact'));

        expect(
          () => repository.downloadArtifact(1, '1.0.0', 'linux', file),
          throwsException,
        );
      });
    });

    group('getAppItchIOData', () {
      test('returns ItchIOData when data exists', () async {
        const storkItchIOData = StorkItchIOData(
          id: 1,
          appId: 2,
          buttlerKey: 'buttlerKey',
          itchIOUsername: 'username',
          itchIOGameName: 'gameName',
        );

        when(() => client.getItchIOData(2))
            .thenAnswer((_) async => storkItchIOData);

        final data = await repository.getAppItchIOData(2);

        expect(
          data,
          equals(
            const ItchIOData(
              id: 1,
              appId: 2,
              buttlerKey: 'buttlerKey',
              itchIOUsername: 'username',
              itchIOGameName: 'gameName',
            ),
          ),
        );

        verify(() => client.getItchIOData(2)).called(1);
      });

      test('returns null when no data exists', () async {
        when(() => client.getItchIOData(2)).thenAnswer((_) async => null);

        final data = await repository.getAppItchIOData(2);

        expect(data, isNull);
        verify(() => client.getItchIOData(2)).called(1);
      });

      test('throws when client throws', () async {
        final exception = Exception('Failed to get ItchIO data');
        when(() => client.getItchIOData(any())).thenThrow(exception);

        expect(
          () => repository.getAppItchIOData(2),
          throwsA(exception),
        );
      });
    });

    group('updateAppItchIOData', () {
      test('updates ItchIO data', () async {
        const storkItchIOData = StorkItchIOData(
          id: 1,
          appId: 2,
          buttlerKey: 'buttlerKey',
          itchIOUsername: 'username',
          itchIOGameName: 'gameName',
        );

        when(
          () => client.updateItchIOData(
            appId: 2,
            buttlerKey: 'buttlerKey',
            itchIOUsername: 'username',
            itchIOGameName: 'gameName',
          ),
        ).thenAnswer((_) async => storkItchIOData);

        final data = await repository.updateAppItchIOData(
          appId: 2,
          buttlerKey: 'buttlerKey',
          itchIOUsername: 'username',
          itchIOGameName: 'gameName',
        );

        expect(
          data,
          equals(
            const ItchIOData(
              id: 1,
              appId: 2,
              buttlerKey: 'buttlerKey',
              itchIOUsername: 'username',
              itchIOGameName: 'gameName',
            ),
          ),
        );

        verify(
          () => client.updateItchIOData(
            appId: 2,
            buttlerKey: 'buttlerKey',
            itchIOUsername: 'username',
            itchIOGameName: 'gameName',
          ),
        ).called(1);
      });

      test('throws when client throws', () async {
        final exception = Exception('Failed to update ItchIO data');
        when(
          () => client.updateItchIOData(
            appId: any(named: 'appId'),
            buttlerKey: any(named: 'buttlerKey'),
            itchIOUsername: any(named: 'itchIOUsername'),
            itchIOGameName: any(named: 'itchIOGameName'),
          ),
        ).thenThrow(exception);

        expect(
          () => repository.updateAppItchIOData(
            appId: 2,
            buttlerKey: 'buttlerKey',
            itchIOUsername: 'username',
            itchIOGameName: 'gameName',
          ),
          throwsA(exception),
        );
      });
    });
  });
}
