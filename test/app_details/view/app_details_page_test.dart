// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/app_details/app_details.dart';
import 'package:stork_hub/l10n/l10n.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockStorkRepository extends Mock implements StorkRepository {}

class MockAppDetailsCubit extends MockCubit<AppDetailsState>
    implements AppDetailsCubit {}

void main() {
  group('AppDetailsPage', () {
    late StorkRepository storkRepository;

    setUp(() {
      storkRepository = MockStorkRepository();
    });

    testWidgets('renders AppDetailsView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppDetailsPage(
            appId: 1,
            storkRepository: storkRepository,
          ),
        ),
      );

      expect(find.byType(AppDetailsView), findsOneWidget);
    });

    test('route returns correct route', () {
      expect(
        AppDetailsPage.route(
          appId: 1,
          storkRepository: storkRepository,
        ),
        isA<MaterialPageRoute<void>>(),
      );
    });
  });

  group('AppDetailsView', () {
    late AppDetailsCubit cubit;

    setUp(() {
      cubit = MockAppDetailsCubit();
    });

    testWidgets('renders loading indicator when status is loading',
        (tester) async {
      when(() => cubit.state).thenReturn(
        const AppDetailsState(status: AppDetailsStatus.loading),
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: AppDetailsView()),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message when status is error', (tester) async {
      when(() => cubit.state).thenReturn(
        const AppDetailsState(
          status: AppDetailsStatus.error,
          error: 'error message',
        ),
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: AppDetailsView()),
          ),
        ),
      );

      expect(find.text('error message'), findsOneWidget);
    });

    testWidgets('renders app details when status is loaded', (tester) async {
      const app = App(id: 1, name: 'Test App', publicMetadata: true);
      final version = Version(
        id: 1,
        appId: app.id,
        version: '1.0.0',
        changelog: 'Initial release',
      );

      when(() => cubit.state).thenReturn(
        AppDetailsState(
          status: AppDetailsStatus.loaded,
          app: app,
          versions: [version],
        ),
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: AppDetailsView()),
          ),
        ),
      );

      expect(find.text('ID: 1'), findsOneWidget);
      expect(find.text('Test App'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Versions'), findsOneWidget);
      expect(find.text('Version: ${version.version}'), findsOneWidget);
      expect(find.text(version.changelog), findsOneWidget);
    });

    testWidgets('renders no versions message when no versions available',
        (tester) async {
      const app = App(id: 1, name: 'Test App', publicMetadata: true);
      when(() => cubit.state).thenReturn(
        const AppDetailsState(
          status: AppDetailsStatus.loaded,
          app: app,
        ),
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: AppDetailsView()),
          ),
        ),
      );

      expect(find.text('No versions available'), findsOneWidget);
    });

    testWidgets('renders multiple versions when available', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();

      tester.view.physicalSize = const Size(1024, 2048);
      tester.view.devicePixelRatio = 1.0;

      const app = App(id: 1, name: 'Test App', publicMetadata: true);
      const versions = [
        Version(
          id: 1,
          appId: 1,
          version: '2.0.0',
          changelog: 'Major update',
        ),
        Version(
          id: 2,
          appId: 1,
          version: '1.1.0',
          changelog: 'Minor update',
        ),
        Version(
          id: 3,
          appId: 1,
          version: '1.0.0',
          changelog: 'Initial release',
        ),
      ];

      final state = AppDetailsState(
        status: AppDetailsStatus.loaded,
        app: app,
        versions: versions,
      );

      when(() => cubit.state).thenReturn(state);
      whenListen(
        cubit,
        Stream.value(state),
        initialState: state,
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: AppDetailsView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find ListView first
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Test each version individually using descendant finder
      for (final version in versions) {
        expect(
          find.descendant(
            of: listView,
            matching: find.text('Version: ${version.version}'),
          ),
          findsOneWidget,
          reason: 'Could not find version ${version.version}',
        );
        expect(
          find.descendant(
            of: listView,
            matching: find.text(version.changelog),
          ),
          findsOneWidget,
        );
      }

      // Verify changelog labels
      expect(
        find.descendant(
          of: listView,
          matching: find.text('Changelog:'),
        ),
        findsNWidgets(3),
      );
    });

    testWidgets('calls updateApp when name is submitted', (tester) async {
      const app = App(id: 1, name: 'Test App', publicMetadata: true);
      when(() => cubit.state).thenReturn(
        const AppDetailsState(
          status: AppDetailsStatus.loaded,
          app: app,
        ),
      );
      when(() => cubit.updateApp(name: 'New Name')).thenAnswer((_) async {});

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: AppDetailsView()),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'New Name');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      verify(() => cubit.updateApp(name: 'New Name')).called(1);
    });

    testWidgets('calls updateApp when public metadata is toggled',
        (tester) async {
      const app = App(id: 1, name: 'Test App', publicMetadata: true);
      when(() => cubit.state).thenReturn(
        const AppDetailsState(
          status: AppDetailsStatus.loaded,
          app: app,
        ),
      );
      when(() => cubit.updateApp(publicMetadata: false))
          .thenAnswer((_) async {});

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: AppDetailsView()),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pump();

      verify(() => cubit.updateApp(publicMetadata: false)).called(1);
    });
  });
}
