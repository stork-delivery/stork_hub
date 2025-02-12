import 'dart:io';

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

  /// Downloads an artifact for a specific version and platform and saves it to
  /// the specified file
  Future<void> downloadArtifact(
    int appId,
    String versionName,
    String platform,
    File file,
  ) async {
    final bytes = await client.downloadArtifact(appId, versionName, platform);
    await file.writeAsBytes(bytes);
  }

  /// Gets the Itch.io integration data for an app
  Future<ItchIOData?> getAppItchIOData(int appId) async {
    final data = await client.getItchIOData(appId);
    if (data == null) {
      return null;
    }
    return ItchIOData(
      id: data.id,
      appId: data.appId,
      buttlerKey: data.buttlerKey,
      itchIOUsername: data.itchIOUsername,
      itchIOGameName: data.itchIOGameName,
    );
  }

  /// Updates the Itch.io integration data for an app
  Future<ItchIOData> updateAppItchIOData({
    required int appId,
    required String buttlerKey,
    required String itchIOUsername,
    required String itchIOGameName,
  }) async {
    final data = await client.updateItchIOData(
      appId: appId,
      buttlerKey: buttlerKey,
      itchIOUsername: itchIOUsername,
      itchIOGameName: itchIOGameName,
    );

    return ItchIOData(
      id: data.id,
      appId: data.appId,
      buttlerKey: data.buttlerKey,
      itchIOUsername: data.itchIOUsername,
      itchIOGameName: data.itchIOGameName,
    );
  }

  /// Lists the news from an app
  Future<List<News>> listNews({
    required int appId,
    required int page,
    required int perPage,
  }) async {
    final news = await client.listNews(
      appId: appId,
      page: page,
      perPage: perPage,
    );
    return news
        .map(
          (news) => News(
            id: news.id,
            title: news.title,
            content: news.content,
            createdAt: news.createdAt,
          ),
        )
        .toList();
  }

  /// Creates a new news article.
  Future<News> createNews({
    required int appId,
    required String title,
    required String content,
  }) async {
    final news = await client.createNews(
      appId: appId,
      title: title,
      content: content,
    );
    return News(
      id: news.id,
      title: news.title,
      content: news.content,
      createdAt: news.createdAt,
    );
  }

  /// Updates an existing news article.
  Future<News> updateNews({
    required int appId,
    required int id,
    required String title,
    required String content,
  }) async {
    final news = await client.updateNews(
      appId: appId,
      newsId: id,
      title: title,
      content: content,
    );
    return News(
      id: news.id,
      title: news.title,
      content: news.content,
      createdAt: news.createdAt,
    );
  }
}
