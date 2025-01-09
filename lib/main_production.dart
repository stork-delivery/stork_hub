import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/bootstrap.dart';
import 'package:stork_hub/environment/app_environment.dart';

void main() {
  const environment = AppEnvironment();
  bootstrap(() => const App(environment: environment));
}
