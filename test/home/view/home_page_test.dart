// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/environment/app_environment.dart';
import 'package:stork_hub/home/home.dart';
import 'package:stork_hub/models/models.dart' as model;

class MockAppCubit extends Mock implements AppCubit {}

class MockHomeCubit extends Mock implements HomeCubit {}

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
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(
              value: const AppEnvironment(
                storkUrl: 'http://test.url',
              ),
            ),
          ],
          child: BlocProvider.value(
            value: appCubit,
            child: const MaterialApp(
              home: HomePage(),
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
      return MaterialApp(
        home: BlocProvider.value(
          value: homeCubit,
          child: const HomeView(),
        ),
      );
    }

    testWidgets('renders loading indicator when loading', (tester) async {
      mockHomeCubitState(const HomeState(status: HomeStatus.loading));
      await tester.pumpWidget(buildSubject());

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

      await tester.pumpWidget(buildSubject());

      expect(find.text('Error: $errorMessage'), findsOneWidget);
    });

    testWidgets('renders empty message when no apps', (tester) async {
      mockHomeCubitState(const HomeState(status: HomeStatus.loaded));
      await tester.pumpWidget(buildSubject());

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

      await tester.pumpWidget(buildSubject());

      expect(find.text('App 1'), findsOneWidget);
      expect(find.text('App 2'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
    });

    testWidgets('tapping delete button calls removeApp', (tester) async {
      const app = model.App(id: 1, name: 'App 1');
      when(() => homeCubit.removeApp(app)).thenAnswer((_) async {});

      mockHomeCubitState(
        const HomeState(status: HomeStatus.loaded, apps: [app]),
      );

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byIcon(Icons.delete));
      verify(() => homeCubit.removeApp(app)).called(1);
    });

    testWidgets('tapping add button shows dialog', (tester) async {
      mockHomeCubitState(const HomeState(status: HomeStatus.loaded));
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddAppDialog), findsOneWidget);
    });
  });
}
