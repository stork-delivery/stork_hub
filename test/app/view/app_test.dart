import 'package:flutter_test/flutter_test.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/environment/app_environment.dart';
import 'package:stork_hub/login/login.dart';

import '../../helpers/helpers.dart';

void main() {
  group('App', () {
    testWidgets('renders LoginPage', (tester) async {
      await tester.pumpApp(
        const App(environment: AppEnvironment()),
      );
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
