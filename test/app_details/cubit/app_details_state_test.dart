import 'package:flutter_test/flutter_test.dart';
import 'package:stork_hub/app_details/cubit/app_details_state.dart';
import 'package:stork_hub/models/models.dart';

void main() {
  group('AppDetailsState', () {
    const app = App(
      id: 1,
      name: 'Test App',
      publicMetadata: true,
    );

    test('supports value equality', () {
      expect(
        const AppDetailsState(),
        equals(const AppDetailsState()),
      );
    });

    test('props are correct', () {
      expect(
        const AppDetailsState(
          status: AppDetailsStatus.loaded,
          app: app,
          error: 'error',
        ).props,
        equals([AppDetailsStatus.loaded, app, 'error', const <Version>[]]),
      );
    });

    group('copyWith', () {
      test('returns the same object if no arguments are provided', () {
        expect(
          const AppDetailsState().copyWith(),
          equals(const AppDetailsState()),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          const AppDetailsState().copyWith(
            status: AppDetailsStatus.loaded,
            app: app,
            error: 'error',
          ),
          equals(
            const AppDetailsState(
              status: AppDetailsStatus.loaded,
              app: app,
              error: 'error',
            ),
          ),
        );
      });
    });
  });
}
