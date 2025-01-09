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
    return apps.map(
      (app) => App(
        id: app.id,
        name: app.name,
      ),
    ).toList();
  }
}
