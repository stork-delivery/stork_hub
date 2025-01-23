import 'package:flutter/widgets.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/bootstrap.dart';
import 'package:stork_hub/environment/app_environment.dart';
import 'package:stork_hub/repositories/api_key_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiKeyRepository = ApiKeyRepository();

  const environment = AppEnvironment();

  await bootstrap(
    () => App(
      environment: environment,
      apiKeyRepository: apiKeyRepository,
    ),
  );
}
