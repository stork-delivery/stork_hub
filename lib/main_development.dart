import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/bootstrap.dart';
import 'package:stork_hub/environment/app_environment.dart';
import 'package:stork_hub/repositories/api_key_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final directory = await getApplicationSupportDirectory();

  final apiKeyRepository = ApiKeyRepository(directory: directory.path);

  const environment = AppEnvironment(
    storkUrl: 'http://localhost:8787',
  );

  await bootstrap(
    () => App(
      environment: environment,
      apiKeyRepository: apiKeyRepository,
    ),
  );
}
