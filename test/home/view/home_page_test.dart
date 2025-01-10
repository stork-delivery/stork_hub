// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/environment/app_environment.dart';
import 'package:stork_hub/home/home.dart';
import 'package:stork_hub/l10n/l10n.dart';
import 'package:stork_hub/models/models.dart' as model;

class MockAppCubit extends Mock implements AppCubit {}

class MockHomeCubit extends Mock implements HomeCubit {}

extension PumpApp on WidgetTester {
  Future<void> pumpHomeView(Widget widget) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    );
  }
}

void main() {
  group('HomePage', () {
    late AppCubit appCubit;

    setUp(() {
      appCubit = MockAppCubit();

      const appState = AppState(apiKey: 'test-api-key');
      whenListen(
        appCubit,
        Stream.value(appState),
        initialState: appState,
      );
    });

    testWidgets('renders HomeView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiRepositoryProvider(
            providers: [
              RepositoryProvider.value(
                value: const AppEnvironment(
                  storkUrl: 'http://test.url',
                ),
              ),
            ],
            child: BlocProvider.value(
              value: appCubit,
              child: const HomePage(),
            ),
          ),
        ),
      );

      expect(find.byType(HomeView), findsOneWidget);
    });
  });

  group('HomeView', () {
    late HomeCubit homeCubit;

    setUp(() {
      homeCubit = MockHomeCubit();
    });

    void mockHomeCubitState(HomeState state) {
      whenListen(
        homeCubit,
        Stream.value(state),
        initialState: state,
      );
    }

    Widget buildSubject() {
      return BlocProvider.value(
        value: homeCubit,
        child: const HomeView(),
      );
    }

    testWidgets('renders loading indicator when loading', (tester) async {
      mockHomeCubitState(const HomeState(status: HomeStatus.loading));
      await tester.pumpHomeView(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message when error occurs', (tester) async {
      const errorMessage = 'Something went wrong';
      mockHomeCubitState(
        const HomeState(
          status: HomeStatus.error,
          error: errorMessage,
        ),
      );

      await tester.pumpHomeView(buildSubject());

      expect(
        find.text('Error: $errorMessage'),
        findsOneWidget,
      );
    });

    testWidgets('renders empty message when no apps', (tester) async {
      mockHomeCubitState(const HomeState(status: HomeStatus.loaded));
      await tester.pumpHomeView(buildSubject());

      expect(find.text('No apps added yet'), findsOneWidget);
    });

    testWidgets('renders list of apps', (tester) async {
      final apps = [
        const model.App(id: 1, name: 'App 1'),
        const model.App(id: 2, name: 'App 2'),
      ];

      mockHomeCubitState(
        HomeState(status: HomeStatus.loaded, apps: apps),
      );

      await tester.pumpHomeView(buildSubject());

      expect(find.text('App 1'), findsOneWidget);
      expect(find.text('App 2'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
    });

    group('delete app', () {
      const app = model.App(id: 1, name: 'App 1');

      setUp(() {
        when(() => homeCubit.removeApp(app)).thenAnswer((_) async {});
        mockHomeCubitState(
          const HomeState(status: HomeStatus.loaded, apps: [app]),
        );
      });

      testWidgets('shows confirmation dialog when delete button tapped',
          (tester) async {
        await tester.pumpHomeView(buildSubject());

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        expect(find.text('Delete App'), findsOneWidget);
        expect(
          find.text('Are you sure you want to delete App 1?'),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('removes app when confirmed', (tester) async {
        await tester.pumpHomeView(buildSubject());

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        verify(() => homeCubit.removeApp(app)).called(1);
      });

      testWidgets('does nothing when canceled', (tester) async {
        await tester.pumpHomeView(buildSubject());

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        verifyNever(() => homeCubit.removeApp(app));
      });
    });

    testWidgets('tapping add button shows dialog', (tester) async {
      mockHomeCubitState(const HomeState(status: HomeStatus.loaded));
      await tester.pumpHomeView(buildSubject());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddAppDialog), findsOneWidget);
    });

    group('AddAppDialog', () {
      testWidgets('adds app when name is not empty', (tester) async {
        when(() => homeCubit.addApp(any())).thenAnswer((_) async {});
        mockHomeCubitState(const HomeState(status: HomeStatus.loaded));

        await tester.pumpHomeView(buildSubject());

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'New App');
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        verify(() => homeCubit.addApp('New App')).called(1);
        expect(find.byType(AddAppDialog), findsNothing);
      });

      testWidgets('does nothing when name is empty', (tester) async {
        when(() => homeCubit.addApp(any())).thenAnswer((_) async {});
        mockHomeCubitState(const HomeState(status: HomeStatus.loaded));

        await tester.pumpHomeView(buildSubject());

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        verifyNever(() => homeCubit.addApp(any()));
        expect(find.byType(AddAppDialog), findsOneWidget);
      });

      testWidgets('closes dialog on cancel', (tester) async {
        mockHomeCubitState(const HomeState(status: HomeStatus.loaded));

        await tester.pumpHomeView(buildSubject());

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.byType(AddAppDialog), findsNothing);
      });
    });
  });
}
