import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/bootstrap.dart';
import 'package:stork_hub/environment/app_environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final directory = await getApplicationSupportDirectory();

  const environment = AppEnvironment(
    storkUrl: 'http://localhost:8787',
  );

  bootstrap(
    () => App(
      environment: environment,
      storageDirectory: directory.path,
    ),
  );
}
