import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/itchio_data/itchio_data.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockStorkRepository extends Mock implements StorkRepository {}

class MockItchIODataCubit extends MockCubit<ItchIODataState>
    implements ItchIODataCubit {}

void main() {
  group('ItchIODataDialog', () {
    late StorkRepository storkRepository;
    late ItchIODataCubit itchIODataCubit;

    const itchIOData = ItchIOData(
      id: 1,
      appId: 1,
      buttlerKey: 'test-key',
      itchIOUsername: 'test-user',
      itchIOGameName: 'test-game',
    );

    setUp(() {
      storkRepository = MockStorkRepository();
      itchIODataCubit = MockItchIODataCubit();

      when(() => itchIODataCubit.state).thenReturn(
        const ItchIODataState(
          status: ItchIODataStatus.loaded,
          data: itchIOData,
        ),
      );

      when(
        () => itchIODataCubit.updateItchIOData(
          buttlerKey: any(named: 'buttlerKey'),
          itchIOUsername: any(named: 'itchIOUsername'),
          itchIOGameName: any(named: 'itchIOGameName'),
        ),
      ).thenAnswer((_) async {});
    });

    Widget buildSubject() {
      return MaterialApp(
        home: RepositoryProvider.value(
          value: storkRepository,
          child: BlocProvider.value(
            value: itchIODataCubit,
            child: const ItchIODataDialog(),
          ),
        ),
      );
    }

    testWidgets('renders correctly when data is loaded', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('ItchIO Integration'), findsOneWidget);
      expect(find.text('Buttler Key'), findsOneWidget);
      expect(find.text('ItchIO Username'), findsOneWidget);
      expect(find.text('Game Name'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      expect(
        find.widgetWithText(TextFormField, 'Buttler Key'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, 'ItchIO Username'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, 'Game Name'),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator when status is loading',
        (tester) async {
      when(() => itchIODataCubit.state).thenReturn(
        const ItchIODataState(status: ItchIODataStatus.loading),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('ItchIO Integration'), findsNothing);
    });

    testWidgets('shows saving indicator when status is saving', (tester) async {
      when(() => itchIODataCubit.state).thenReturn(
        const ItchIODataState(status: ItchIODataStatus.saving),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Saving ItchIO data...'), findsOneWidget);
      expect(find.text('ItchIO Integration'), findsNothing);
    });

    testWidgets('shows error message when error is present', (tester) async {
      when(() => itchIODataCubit.state).thenReturn(
        const ItchIODataState(
          status: ItchIODataStatus.loaded,
          error: 'Test error message',
        ),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('validates empty fields', (tester) async {
      await tester.pumpWidget(buildSubject());

      // Clear all fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Buttler Key'),
        '',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'ItchIO Username'),
        '',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Game Name'),
        '',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a Buttler key'), findsOneWidget);
      expect(find.text('Please enter your ItchIO username'), findsOneWidget);
      expect(find.text('Please enter your game name'), findsOneWidget);

      verifyNever(
        () => itchIODataCubit.updateItchIOData(
          buttlerKey: any(named: 'buttlerKey'),
          itchIOUsername: any(named: 'itchIOUsername'),
          itchIOGameName: any(named: 'itchIOGameName'),
        ),
      );
    });

    testWidgets('calls updateItchIOData when form is valid', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Buttler Key'),
        'new-key',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'ItchIO Username'),
        'new-user',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Game Name'),
        'new-game',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(
        () => itchIODataCubit.updateItchIOData(
          buttlerKey: 'new-key',
          itchIOUsername: 'new-user',
          itchIOGameName: 'new-game',
        ),
      ).called(1);
    });

    testWidgets('closes dialog when cancel is pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => RepositoryProvider.value(
                    value: storkRepository,
                    child: BlocProvider.value(
                      value: itchIODataCubit,
                      child: const ItchIODataDialog(),
                    ),
                  ),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(ItchIODataDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(ItchIODataDialog), findsNothing);
    });
  });
}
