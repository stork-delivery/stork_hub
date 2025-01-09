import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/bootstrap.dart';
import 'package:stork_hub/environment/app_environment.dart';

void main() {
  const environment = AppEnvironment(storkUrl: 'http://localhost:8787');
  bootstrap(() => const App(environment: environment));
}
