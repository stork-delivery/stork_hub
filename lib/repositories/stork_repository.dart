import 'package:dart_stork_admin_client/dart_stork_admin_client.dart';
import 'package:stork_hub/models/models.dart';

/// Repository responsible for interacting with the Stork service.
class StorkRepository {
  /// Creates a new [StorkRepository] instance.
  const StorkRepository({
    required this.client,
  });

  /// The client used to make requests to the Stork service.
  final DartStorkAdminClient client;

  /// Lists all available apps.
  Future<List<App>> listApps() async {
    final apps = await client.listApps();
    return apps
        .map(
          (app) => App(
            id: app.id,
            name: app.name,
            publicMetadata: app.publicMetadata,
          ),
        )
        .toList();
  }

  /// Creates a new app.
  Future<App> createApp({
    required String name,
    bool publicMetadata = false,
  }) async {
    final app = await client.createApp(
      name: name,
      publicMetadata: publicMetadata,
    );
    return App(
      id: app.id,
      name: app.name,
      publicMetadata: app.publicMetadata,
    );
  }

  /// Removes an app.
  Future<void> removeApp(int id) async {
    await client.removeApp(id);
  }

  /// Updates an app.
  Future<App> updateApp({
    required int id,
    String? name,
    bool? publicMetadata,
  }) async {
    final app = await client.updateApp(
      id: id,
      name: name,
      publicMetadata: publicMetadata,
    );
    return App(
      id: app.id,
      name: app.name,
      publicMetadata: app.publicMetadata,
    );
  }

  /// Gets an app by its id
  Future<App> getApp(int id) async {
    final app = await client.getApp(id);
    return App(
      id: app.id,
      name: app.name,
      publicMetadata: app.publicMetadata,
    );
  }

  /// Gets a list of versions for an app
  Future<List<Version>> listAppVersions(int appId) async {
    final versions = await client.listVersions(appId);
    return versions
        .map(
          (version) => Version(
            id: version.id,
            appId: version.appId,
            version: version.version,
            changelog: version.changelog,
          ),
        )
        .toList();
  }

  /// Gets a specific version of an app
  Future<Version> getAppVersion(int appId, String versionName) async {
    final version = await client.getVersion(appId, versionName);
    return Version(
      id: version.id,
      appId: version.appId,
      version: version.version,
      changelog: version.changelog,
    );
  }

  /// Gets a list of artifacts for a specific version of an app
  Future<List<Artifact>> listAppVersionArtifacts(
    int appId,
    String versionName,
  ) async {
    final artifacts = await client.listArtifacts(appId, versionName);
    return artifacts
        .map(
          (artifact) => Artifact(
            id: artifact.id,
            name: artifact.name,
            versionId: artifact.versionId,
            platform: artifact.platform,
          ),
        )
        .toList();
  }
}
