// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/l10n/l10n.dart';
import 'package:stork_hub/login/login.dart';

class MockAppCubit extends Mock implements AppCubit {}

class MockLoginCubit extends Mock implements LoginCubit {}

extension PumpApp on WidgetTester {
  Future<void> pumpLoginForm(Widget widget) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: widget),
      ),
    );
  }
}

void main() {
  group('LoginForm', () {
    late AppCubit appCubit;
    late LoginCubit loginCubit;

    void mockAppCubitState(AppState state) {
      whenListen(appCubit, Stream.value(state), initialState: state);
    }

    void mockLoginCubitState(LoginState state) {
      whenListen(loginCubit, Stream.value(state), initialState: state);
    }

    setUp(() {
      appCubit = MockAppCubit();
      loginCubit = MockLoginCubit();

      mockAppCubitState(const AppState());
      mockLoginCubitState(const LoginState());

      when(
        () => appCubit.saveAndSetApiKey(
          apiKey: any(named: 'apiKey'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      when(() => appCubit.unlockWithPassword(any()))
          .thenAnswer((_) async => true);

      when(() => loginCubit.resetKey()).thenAnswer((_) async {});
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: appCubit,
        child: BlocProvider.value(
          value: loginCubit,
          child: const LoginForm(),
        ),
      );
    }

    group('initial state', () {
      testWidgets('shows API key field when no saved key', (tester) async {
        await tester.pumpLoginForm(buildSubject());

        expect(find.widgetWithText(TextField, 'API Key'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
        expect(find.text('Reset API Key'), findsNothing);
      });

      testWidgets('hides API key field when has saved key', (tester) async {
        mockLoginCubitState(const LoginState(hasSavedKey: true));
        await tester.pumpLoginForm(buildSubject());

        expect(find.widgetWithText(TextField, 'API Key'), findsNothing);
        expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Unlock'), findsOneWidget);
        expect(find.text('Reset API Key'), findsOneWidget);
      });
    });

    group('when loading', () {
      testWidgets('shows loading indicator', (tester) async {
        mockLoginCubitState(const LoginState(loading: true));
        await tester.pumpLoginForm(buildSubject());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('login button', () {
      testWidgets(
        'shows error when fields are empty with no saved key',
        (tester) async {
          await tester.pumpLoginForm(buildSubject());

          await tester.tap(find.text('Login'));
          await tester.pumpAndSettle();

          expect(find.text('Please fill in all fields'), findsOneWidget);
        },
      );

      testWidgets(
        'shows error when password is empty with saved key',
        (tester) async {
          mockLoginCubitState(const LoginState(hasSavedKey: true));
          await tester.pumpLoginForm(buildSubject());

          await tester.tap(find.text('Unlock'));
          await tester.pumpAndSettle();

          expect(find.text('Please enter your password'), findsOneWidget);
        },
      );

      testWidgets(
        'shows error when password is invalid',
        (tester) async {
          when(() => appCubit.unlockWithPassword(any()))
              .thenAnswer((_) async => false);

          mockLoginCubitState(const LoginState(hasSavedKey: true));
          await tester.pumpLoginForm(buildSubject());

          await tester.enterText(
            find.widgetWithText(TextField, 'Password'),
            'password',
          );
          await tester.tap(find.text('Unlock'));
          await tester.pumpAndSettle();

          expect(find.text('Invalid password'), findsOneWidget);
        },
      );

      testWidgets(
        'saves and sets API key when fields are filled',
        (tester) async {
          await tester.pumpLoginForm(buildSubject());

          await tester.enterText(
            find.widgetWithText(TextField, 'API Key'),
            'api-key',
          );
          await tester.enterText(
            find.widgetWithText(TextField, 'Password'),
            'password',
          );
          await tester.tap(find.text('Login'));

          verify(
            () => appCubit.saveAndSetApiKey(
              apiKey: 'api-key',
              password: 'password',
            ),
          ).called(1);
        },
      );

      testWidgets(
        'unlocks with password when has saved key',
        (tester) async {
          mockLoginCubitState(const LoginState(hasSavedKey: true));
          await tester.pumpLoginForm(buildSubject());

          await tester.enterText(
            find.widgetWithText(TextField, 'Password'),
            'password',
          );
          await tester.tap(find.text('Unlock'));

          verify(() => appCubit.unlockWithPassword('password')).called(1);
        },
      );
    });

    group('reset API key button', () {
      testWidgets('shows confirmation dialog', (tester) async {
        mockLoginCubitState(const LoginState(hasSavedKey: true));
        await tester.pumpLoginForm(buildSubject());

        await tester.tap(find.text('Reset API Key'));
        await tester.pumpAndSettle();

        expect(find.text('Reset API Key'), findsNWidgets(2));
        expect(
          find.text(
            'Are you sure you want to reset your API key? '
            'You will need to enter it again.',
          ),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Reset'), findsOneWidget);
      });

      testWidgets('resets key when confirmed', (tester) async {
        mockLoginCubitState(const LoginState(hasSavedKey: true));
        await tester.pumpLoginForm(buildSubject());

        await tester.tap(find.text('Reset API Key'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset'));
        verify(() => loginCubit.resetKey()).called(1);
      });

      testWidgets('does nothing when canceled', (tester) async {
        mockLoginCubitState(const LoginState(hasSavedKey: true));
        await tester.pumpLoginForm(buildSubject());

        await tester.tap(find.text('Reset API Key'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        verifyNever(() => loginCubit.resetKey());
      });
    });
  });
}
